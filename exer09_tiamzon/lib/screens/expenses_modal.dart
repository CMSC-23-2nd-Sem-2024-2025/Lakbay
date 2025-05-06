import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expenses_user_model.dart';
import '../providers/expenses_provider.dart';

// ignore: must_be_immutable
class ExpenseModal extends StatelessWidget {
  final String type;
  final Expenses? item;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  FoodCategory _selectedCategory;

  ExpenseModal({super.key, required this.type, this.item})
    : _selectedCategory = item?.category ?? FoodCategory.miscellaneous {
    if (item != null) {
      _nameController.text = item!.name ?? '';
      _descriptionController.text = item!.description ?? '';
      _amountController.text = item!.amount?.toString() ?? '';
    }
  }

  Text _buildTitle() {
    switch (type) {
      case 'Add':
        return const Text("Add Expense");
      case 'Edit':
        return const Text("Edit Expense");
      case 'Delete':
        return const Text("Delete Expense");
      default:
        return const Text("");
    }
  }

  // form fields for the details of expenses tracker
  Widget _buildContent(BuildContext context) {
    switch (type) {
      case 'Delete':
        return Text("Are you sure you want to delete '${item!.name}'?");
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name Text Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.green), // Label color
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ), // Border color when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ), // Border color when enabled
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Text Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.green), // Label color
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ), // Border color when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ), // Border color when enabled
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Text Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: const TextStyle(color: Colors.green), // Label color
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ), // Border color when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ), // Border color when enabled
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<FoodCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: Colors.green), // Label color
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ), // Border color when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ), // Border color when enabled
                ),
              ),
              items:
                  FoodCategory.values.map((FoodCategory category) {
                    return DropdownMenuItem<FoodCategory>(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
              onChanged: (value) {
                _selectedCategory = value!;
              },
            ),
          ],
        );
    }
  }

  TextButton _dialogAction(BuildContext context) {
    return TextButton(
      onPressed: () {
        switch (type) {
          // case when the user wants to add expenses
          case 'Add':
            {
              // condition if the fields don't have inputs or details
              if (_nameController.text.isEmpty ||
                  _descriptionController.text.isEmpty ||
                  _amountController.text.isEmpty) {
                // Handle empty input
                return;
              }

              // enables the combination of string and integer for amount
              double? parsedAmount = double.tryParse(_amountController.text);
              if (parsedAmount == null) {
                // Handle invalid numeric input
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              // for textcontrollers in each fields
              Expenses temp = Expenses(
                name: _nameController.text,
                description: _descriptionController.text,
                category: _selectedCategory,
                amount: parsedAmount,
                paid: null,
              );

              context.read<ExpenseListProvider>().addTodo({
                'name': temp.name,
                'description': temp.description,
                'category': temp.category.toString(),
                'amount': temp.amount,
              });
              Navigator.of(context).pop();
              break;
            }

          // case when the user wants to edit existing expenses
          case 'Edit':
            {
              if (item != null) {
                double? parsedAmount = double.tryParse(_amountController.text);
                if (parsedAmount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                context.read<ExpenseListProvider>().editTodo(item!.id!, {
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                  'amount': parsedAmount,
                  'category': _selectedCategory.toString(),
                });
              }
              Navigator.of(context).pop();
              break;
            }

          // case when the user wants to delete expenses
          case 'Delete':
            {
              if (item != null) {
                context.read<ExpenseListProvider>().deleteTodo(item!.id!);
              }
              Navigator.of(context).pop();
              break;
            }
        }
      },
      style: TextButton.styleFrom(
        foregroundColor:
            type == 'Edit'
                ? Colors.green
                : null, // Change font color for "Edit"
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Text(type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: Material(
        type: MaterialType.transparency, // Ensures it blends with the dialog
        child: _buildContent(context),
      ),
      actions: <Widget>[
        _dialogAction(context),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
