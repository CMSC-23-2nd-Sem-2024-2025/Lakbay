import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expenses_user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/expenses_provider.dart';
import 'expenses_modal.dart';
import 'expenses_input.dart';
import '../common/drawer.dart';

class ExpenseInitPage extends StatefulWidget {
  const ExpenseInitPage({super.key});

  @override
  State<ExpenseInitPage> createState() => _ExpenseInitPageState();
}

class _ExpenseInitPageState extends State<ExpenseInitPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ExpenseListProvider>()
        .fetchTodos(); // Fetch expenses for the signed-in user
  }

  @override
  Widget build(BuildContext context) {
    // access the list of expenses from the provider
    Stream<QuerySnapshot<Object?>>? expensesStream =
        context.watch<ExpenseListProvider>().expenses;

    // get the current authenticated user
    // allows the user to access their own details in the expense form
    User? currentUser = context.watch<AuthProvider>().userObj;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        backgroundColor: const Color(0xFFFBBD8A3),
      ),

      // Add the drawer widget
      drawer: DrawerWidget(user: currentUser),

      body: StreamBuilder(
        stream: expensesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Expenses Found"));
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              // Parse the expense data from Firestore
              Expenses expense = Expenses.fromJson(
                snapshot.data?.docs[index].data() as Map<String, dynamic>,
              );

              expense.id = snapshot.data?.docs[index].id;

              // Use Dismissible to allow deleting expenses
              return Dismissible(
                key: Key(expense.id.toString()),
                onDismissed: (direction) async {
                  bool confirm = await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                            "Are you sure you want to delete this expense?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Colors.grey, // Cancel button color
                              ),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Colors.red, // Delete button color
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                  );

                  // If confirmed, delete the expense
                  if (confirm) {
                    context.read<ExpenseListProvider>().deleteTodo(expense.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${expense.name} dismissed')),
                    );
                  }
                },
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: expense.paid ?? false,
                    activeColor: Colors.green, // Custom color for "paid"
                    onChanged: (bool? value) {
                      if (expense.id != null) {
                        context.read<ExpenseListProvider>().toggleStatus(
                          expense.id!,
                          value ?? false,
                        );
                      }
                    },
                  ),
                  title: Text(expense.name ?? 'No name'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Open the edit modal
                          showDialog(
                            context: context,
                            builder:
                                (BuildContext context) =>
                                    ExpenseModal(type: 'Edit', item: expense),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          // Open the delete modal
                          showDialog(
                            context: context,
                            builder:
                                (BuildContext context) =>
                                    ExpenseModal(type: 'Delete', item: expense),
                          );
                        },
                        icon: const Icon(Icons.delete_outlined),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Floating action button to add a new expense
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add expense page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpensesInput()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 132, 221, 135),
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
