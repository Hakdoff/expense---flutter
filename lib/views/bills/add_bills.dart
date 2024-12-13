import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/bills_services.dart';
import 'package:flutter_expense_tracker/views/bills/bills_page.dart';

class AddBills extends StatefulWidget {
  const AddBills({super.key});

  @override
  State<AddBills> createState() => _AddBillsState();
}

class _AddBillsState extends State<AddBills> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory;

  final List<Map<String, String>> categories = [
    {'value': "GYM", 'label': "Gym"},
    {'value': "LIFE INSURANCE", 'label': "Life Insurance"},
    {'value': "ALLOWANCE", 'label': "Bahay"},
    {'value': "BAHAY", 'label': "Apartment"},
    {'value': "APARTMENT", 'label': "Emergency Fund"},
    {'value': "SAVINGS FUND", 'label': "Savings"},
    {'value': "EXTRA", 'label': "Extra"},
  ];

  void addBillsPage() async {
    if (_amountController.text.isEmpty ||
        _itemController.text.isEmpty ||
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

      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid amount or date format')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await addBills(
          context, amount, _selectedCategory!, _itemController.text);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income added successfully')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BillsPage()),
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
        title: const Text('Add Bills'),
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
                      controller: _itemController,
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
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addBillsPage,
                      child: const Text('Add Income'),
                    ),
                  ],
                )),
    );
  }
}
