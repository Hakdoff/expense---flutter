import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/model/expense_model.dart';
import 'package:flutter_expense_tracker/services/expense_service.dart';
import 'package:flutter_expense_tracker/views/expense/add_expense.dart';
import 'package:flutter_expense_tracker/views/expense/edit_expense.dart';
import 'package:flutter_expense_tracker/views/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> _expenses = [];
  String? _errorMessages;
  bool _isLoading = false;

  Future<void> _fetchAllExpenses() async {
    setState(() {
      _isLoading = true;
    });

    final result = await fetchExpenses(context);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final expenseData = result['data'] as List<dynamic>;

        _expenses = expenseData
            .map((expenseJson) => ExpenseModel.fromJson(expenseJson))
            .toList();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expenses fetch successfully')));
      } else {
        _errorMessages = result['message'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Expanded(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('${expense.category ?? 'N/A'}'),
                        subtitle: Text(
                          expense.dateSpended != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(expense.dateSpended!)
                              : 'N/A',
                        ),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            children: [
                              Text(
                                '\$ ${expense.amount ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.green),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'Edit') {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditExpensePage(
                                                  expense: expense,
                                                )));
                                  } else if (value == 'Delete') {
                                    final result = await deleteExpense(
                                        context, expense.id);

                                    if (result['success']) {
                                      setState(() {
                                        _expenses.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Income deleted successfully")));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result['message'] ??
                                                'Failed to delete income.')),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem(
                                        value: 'Edit',
                                        child: ListTile(
                                            leading: Icon(Icons.edit),
                                            title: Text('Edit'))),
                                    const PopupMenuItem(
                                        value: 'Delete',
                                        child: ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('Delete')))
                                  ];
                                },
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ),
                      ));
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const AddExpense()));
                },
                child: const Icon(Icons.add),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
