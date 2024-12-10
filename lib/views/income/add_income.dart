import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/income_service.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';
import 'package:intl/intl.dart';

class AddIncome extends StatefulWidget {
  const AddIncome({super.key});

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory;

  final List<Map<String, String>> categories = [
    {'value': "SALARY", 'label': "Salary"},
    {'value': "ALLOWANCE", 'label': "Allowance"},
    {'value': "GIFT", 'label': "Gift"},
    {'value': "OTHER", 'label': "Other"},
  ];

  void _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // set the earliest date
      lastDate: DateTime(2101), // set the latest date
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd')
            .format(selectedDate); // Format as YYYY-MM-DD
      });
    }
  }

  void _addIncome() async {
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
      final date = DateTime.tryParse(_dateController.text);

      if (amount == null || date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid amount or date format')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await addIncome(context, amount,
          _descriptionController.text, _selectedCategory!, date);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income added successfully')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IncomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message'] ?? 'Failed to add Income')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IncomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Amount'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
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
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  TextField(
                    controller: _dateController,
                    keyboardType: TextInputType.datetime,
                    decoration:
                        const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    onTap: () {
                      FocusScope.of(context).requestFocus(
                          FocusNode()); // To prevent the keyboard from showing
                      _selectDate(context); // Open the date picker
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addIncome,
                    child: const Text('Add Income'),
                  ),
                ],
              ),
      ),
    );
  }
}
