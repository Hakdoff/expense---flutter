import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/model/income_model.dart';
import 'package:flutter_expense_tracker/services/income_service.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';
import 'package:intl/intl.dart';

class EditIncomePage extends StatefulWidget {
  final IncomeModel income;

  const EditIncomePage({Key? key, required this.income}) : super(key: key);

  @override
  State<EditIncomePage> createState() => _EditIncomePageState();
}

class _EditIncomePageState extends State<EditIncomePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.income.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.income.description);
    _categoryController = TextEditingController(text: widget.income.category);
    _dateController = TextEditingController(
        text: widget.income.dateReceived != null
            ? DateFormat('yyyy-MM-dd').format(widget.income.dateReceived!)
            : '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _editIncome() async {
    try {
      if (_formKey.currentState!.validate()) {
        final dateReceived = _dateController.text.isNotEmpty
            ? DateTime.tryParse(_dateController.text)
            : null;
        final result = await editIncome(
            context,
            widget.income.id,
            int.parse(_amountController.text),
            _descriptionController.text,
            _categoryController.text,
            dateReceived);
        print('EDit $result');

        if (result != null && result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Income updated successfully")));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const IncomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? 'Failed to update income')));
        }
      }
    } catch (e) {
      // Catch any exception during the process
      print("Error during income update: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred while updating income')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Income'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.none,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an amount' : null),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a category' : null,
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration:
                        const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a date';
                      try {
                        DateTime.parse(value);
                        return null;
                      } catch (e) {
                        return 'Invalid date format';
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _editIncome,
                    child: const Text('Update'),
                  ),
                ],
              )),
        ));
  }
}
