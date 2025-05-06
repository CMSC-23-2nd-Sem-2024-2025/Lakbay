import 'package:exer08_tiamzon/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expenses_user_model.dart';

class ExpensesInput extends StatefulWidget {
  const ExpensesInput({super.key});

  @override
  State<ExpensesInput> createState() => _ExpensesInputState();
}

class _ExpensesInputState extends State<ExpensesInput> {
  final _formKey = GlobalKey<FormState>();

  // this would allows to have an input in a form field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  FoodCategory _selectedCategory = FoodCategory.miscellaneous;

  // dispose the previous data
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // method for submitting the details from form fields
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      double? parsedAmount = double.tryParse(_amountController.text);
      if (parsedAmount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      Expenses newExpenses = Expenses(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        amount: parsedAmount,
        paid: null,
      );

      context.read<ExpenseListProvider>().addTodo(newExpenses.toJson());
      Navigator.of(context).pop(); // Close the form after submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        backgroundColor: Color(0xfffbbd8a3),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Text Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Text Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Text Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    FoodCategory.values.map((FoodCategory category) {
                      return DropdownMenuItem<FoodCategory>(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button background color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
