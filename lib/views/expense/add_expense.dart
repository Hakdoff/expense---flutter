import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/expense_service.dart';
import 'package:flutter_expense_tracker/views/expense/expense_page.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory;

  final List<Map<String, String>> categories = [
    {'value': "FOOD", 'label': "Food"},
    {'value': "TRANSPORTATION", 'label': "Transportation"},
    {'value': "CLOTHING", 'label': "Clothing"},
    {'value': "BILLS", 'label': "Bills"},
    {'value': "HEALTHCARE", 'label': "Healthcare"},
    {'value': "UTILITIES", 'label': "Utilities"},
    {'value': "RENT", 'label': "Rent"},
    {'value': "SKINCARE", 'label': "Skincare"},
    {'value': "GYM", 'label': "Gym"},
    {'value': "GROCERY", 'label': "Grocery"},
    {'value': "FAMILY", 'label': "Family"},
    {'value': "OTHER", 'label': "Other"},
  ];

  void _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _addExpense() async {
    if (_amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      final amount = int.tryParse(_amountController.text);
      final date = DateTime.parse(_dateController.text);

      if (amount == null || date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid date or amount')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await addExpenses(context, amount, _selectedCategory!,
          _descriptionController.text, date);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense added successfully')));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ExpensePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message'] ?? 'Failed to add Expense')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(16),
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Amount'),
                      ),
                      TextField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category['value'],
                            child: Text(category['label']!),
                          );
                        }).toList(),
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      TextField(
                        controller: _dateController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                            labelText: 'Date (YYYY-MM-DD)'),
                        onTap: () {
                          FocusScope.of(context).requestFocus(
                              FocusNode()); // To prevent the keyboard from showing
                          _selectDate(context); // Open the date picker
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addExpense,
                        child: const Text('Add Income'),
                      ),
                    ],
                  )));
  }
}
