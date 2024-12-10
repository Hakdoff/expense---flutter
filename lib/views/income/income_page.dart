import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/model/income_model.dart';
import 'package:flutter_expense_tracker/services/income_service.dart';
import 'package:flutter_expense_tracker/views/home_page.dart';
import 'package:flutter_expense_tracker/views/income/add_income.dart';
import 'package:flutter_expense_tracker/views/income/edit_income.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> _incomes = [];
  String? _errorMessage;
  bool _isLoading = false;

  int? selectedYear;
  int? selectedMonth;

  Future<void> _fetchAllIncomes() async {
    setState(() {
      _isLoading = true;
    });

    final result = await fetchAllIncomes(context);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final incomesData = result['data'] as List<dynamic>;

        _incomes = incomesData
            .map((incomeJson) => IncomeModel.fromJson(incomeJson))
            .toList();
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    _fetchAllIncomes();
  }

  Widget _getCategoryIcon(String category) {
    Color iconColor;
    IconData icon;
    switch (category.toLowerCase()) {
      case 'salary':
        icon = Icons.monetization_on;
        iconColor = Colors.green;
        break;
      case 'gift':
        icon = Icons.card_giftcard;
        iconColor = Colors.red;
        break;
      case 'allowance':
        icon = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        break;
      case 'other':
        icon = Icons.more_horiz;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.category;
        iconColor = Colors.grey;
        break;
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double calculateTotalIncome({int? year, int? month}) {
      return _incomes.where((income) {
        DateTime? date = income.dateReceived;
        if (date == null) return false;
        bool matchesYear = year == null || date.year == year;
        bool matchesMonth = month == null || date.month == month;
        return matchesYear && matchesMonth;
      }).fold(0.0, (sum, income) => sum + (income.amount ?? 0));
    }

    double calculateIncomeYear({
      int? year,
    }) {
      return _incomes.where((income) {
        DateTime? date = income.dateReceived;
        if (date == null) return false;
        bool matchesYear = year == null || date.year == year;
        return matchesYear;
      }).fold(0.0, (sum, income) => sum + (income.amount ?? 0));
    }

    double calculateIncomeMonth({int? month}) {
      return _incomes.where((income) {
        DateTime? date = income.dateReceived;
        if (date == null) return false;
        bool matchesMonth = month == null || date.month == month;
        return matchesMonth;
      }).fold(0.0, (sum, income) => sum + (income.amount ?? 0));
    }

    double totalIncome = calculateTotalIncome();

    double monthIncome = calculateIncomeMonth(month: selectedMonth);
    double yearIncome = calculateIncomeYear(year: selectedYear);
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("All Incomes"),
        ),
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
                                    " \$ ${totalIncome.toStringAsFixed(2)}",
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
                                    '\$ ${monthIncome.toStringAsFixed(0)}',
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
                                    yearIncome.toStringAsFixed(2),
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
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ListView.builder(
                      itemCount: _incomes.length,
                      itemBuilder: (context, index) {
                        final income = _incomes[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _getCategoryIcon(income.category ?? ''),
                            title: Text('${income.category ?? 'N/A'}'),
                            subtitle: Text(
                              income.dateReceived != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(income.dateReceived!)
                                  : 'N/A',
                            ),
                            trailing: SizedBox(
                              width: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$ ${income.amount ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.green),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'Edit') {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditIncomePage(
                                                      income: income,
                                                    )));
                                      } else if (value == 'Delete') {
                                        final result = await deleteIncome(
                                            context, income.id);

                                        if (result['success']) {
                                          setState(() {
                                            _incomes.removeAt(index);
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
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const AddIncome()));
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
