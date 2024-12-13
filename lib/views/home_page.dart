import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/model/expense_model.dart';
import 'package:flutter_expense_tracker/model/income_model.dart';
import 'package:flutter_expense_tracker/services/expense_service.dart';
import 'package:flutter_expense_tracker/services/income_service.dart';
import 'package:flutter_expense_tracker/views/bills/bills_page.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _incomes = [];
  List<dynamic> _expenses = [];
  List<dynamic> _recentTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _totalBalance = 0.0;

  Future<void> _fetchAllTransactions() async {
    setState(() {
      _isLoading = true;
      _totalIncome = 0.0;
      _totalExpense = 0.0;
    });

    final expensesResult = await fetchExpenses(context);
    final incomeResult = await fetchAllIncomes(context);

    setState(() {
      _isLoading = false;
      if (expensesResult['success'] == true &&
          incomeResult['success'] == true) {
        final expenseData = expensesResult['data'] as List<dynamic>;
        final incomeData = incomeResult['data'] as List<dynamic>;

        _incomes = incomeData
            .map((incomeJson) => IncomeModel.fromJson(incomeJson))
            .toList();

        _expenses = expenseData
            .map((expenseJson) => ExpenseModel.fromJson(expenseJson))
            .toList();

        final currentYear = DateTime.now().year;
        _totalIncome = _incomes
            .where((income) => income.date?.year == currentYear)
            .fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));

        _totalExpense = _expenses
            .where((expense) => expense.date?.year == currentYear)
            .fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));

        _totalBalance = _totalIncome - _totalExpense;

        _recentTransactions = [
          ..._incomes.map((income) => {
                'id': income.id,
                'amount': income.amount,
                'description': income.description,
                'category': income.category,
                'date': income.date?.toIso8601String(),
                'type': 'Income'
              }),
          ..._expenses.map((expense) => {
                'id': expense.id,
                'amount': expense.amount,
                'description': expense.description,
                'category': expense.category,
                'date': expense.date?.toIso8601String(),
                'type': 'Expense'
              }),
        ]..sort((a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

        _recentTransactions = _recentTransactions.take(10).toList();
      } else {
        _errorMessage = incomeResult['message'] ?? expensesResult['message'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.amber,
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.width * 0.4,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Balance'),
                    Text(
                      '\$${_totalBalance.toStringAsFixed(2)}',
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Expense"),
                        Text(
                          '\$${_totalExpense.toStringAsFixed(2)}',
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text("Income"),
                        Text(
                          '\$${_totalIncome.toStringAsFixed(2)}',
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Wrap(
          spacing: 16.0, // Space between the items horizontally
          runSpacing: 16.0, // Space between the rows vertically
          children: [
            Card(
                child: IconButton(
                    onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const IncomePage()))
                        },
                    icon: const Icon(Icons.account_balance_wallet))),
            Card(
                child: IconButton(
                    onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const IncomePage()))
                        },
                    icon: const Icon(Icons.attach_money))),
            Card(
                child: IconButton(
                    onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const IncomePage()))
                        },
                    icon: const Icon(Icons.savings))),
            Card(
                child: IconButton(
                    onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const IncomePage()))
                        },
                    icon: const Icon(Icons.favorite_border))),
            Card(
                child: IconButton(
                    onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const BillsPage()))
                        },
                    icon: const Icon(Icons.receipt))),
          ],
        ),
        const Divider(),
        Expanded(
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _recentTransactions[index];
                      return ListTile(
                          title: Text(transaction['category'] ?? ''),
                          subtitle: Text(transaction['description'] ?? ''),
                          trailing: Text(
                            "${transaction['type'] == 'Income' ? '+' : '-'} \$${transaction['amount']}",
                            style: TextStyle(
                              color: transaction['type'] == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ));
                    },
                  ))),
        )
      ],
    ));
  }
}
