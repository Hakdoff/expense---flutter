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

  int? selectedYear;
  int? selectedMonth;

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
    DateTime now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    _fetchAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    double calculateTotalExpense({int? year, int? month}) {
      return _expenses.where((expense) {
        DateTime? date = expense.date;
        if (date == null) return false;
        bool matchesYear = year == null || date.year == year;
        bool matchesMonth = month == null || date.month == month;
        return matchesYear && matchesMonth;
      }).fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
    }

    double calculateExpenseYear({int? year}) {
      return _expenses.where((expense) {
        DateTime? date = expense.date;
        if (date == null) return false;
        bool matchesYear = year == null || date.year == year;
        return matchesYear;
      }).fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
    }

    double calculateExpenseMonth({int? month}) {
      return _expenses.where((expense) {
        DateTime? date = expense.date;
        if (date == null) return false;
        bool matchesMonth = month == null || date.month == month;
        return matchesMonth;
      }).fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
    }

    double totalExpenses = calculateTotalExpense();
    double monthlyExpenses = calculateExpenseMonth(month: selectedMonth);
    double yearlyExpenses = calculateExpenseYear(year: selectedYear);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  color: Colors.yellow,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Total Income:',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    " \$ ${totalExpenses.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  DropdownButton<int>(
                                      hint: const Text("Month",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20)),
                                      value: selectedMonth,
                                      icon: const Icon(
                                        Icons.date_range,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      items: List.generate(12, (index) {
                                        return DropdownMenuItem<int>(
                                          value: index + 1,
                                          child: Text(DateFormat.MMMM()
                                              .format(DateTime(0, index + 1))),
                                        );
                                      }),
                                      onChanged: (month) {
                                        setState(() {
                                          selectedMonth = month;
                                        });
                                      }),
                                  Text(
                                    '\$ ${monthlyExpenses.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  DropdownButton<int>(
                                      hint: const Text("Year ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20)),
                                      value: selectedYear,
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      items: List.generate(
                                        10,
                                        (index) => 2020 + index,
                                      ).map((year) {
                                        return DropdownMenuItem<int>(
                                            value: year,
                                            child: Text(year.toString()));
                                      }).toList(),
                                      onChanged: (year) {
                                        setState(() {
                                          selectedYear = year;
                                        });
                                      }),
                                  Text(
                                    yearlyExpenses.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    'Transactions',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
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
                                  expense.date != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(expense.date!)
                                      : 'N/A',
                                ),
                                trailing: SizedBox(
                                  width: 150,
                                  child: Row(
                                    children: [
                                      Text(
                                        '- \$ ${expense.amount ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'Edit') {
                                            Navigator.of(context)
                                                .pushReplacement(
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
                                                    content: Text(result[
                                                            'message'] ??
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
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const AddExpense()));
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
