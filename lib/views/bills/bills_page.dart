import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/model/bills_model.dart';
import 'package:flutter_expense_tracker/services/bills_services.dart';
import 'package:flutter_expense_tracker/services/income_service.dart';
import 'package:flutter_expense_tracker/views/bills/add_bills.dart';
import 'package:flutter_expense_tracker/views/home_page.dart';
import 'package:flutter_expense_tracker/views/income/add_income.dart';
import 'package:flutter_expense_tracker/views/income/edit_income.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> _bills = [];
  String? _errorMessage;
  bool _isLoading = false;

  int? selectedYear;
  int? selectedMonth;
  double _totalBills = 0.0;

  Future<void> _fetchAllBills() async {
    setState(() {
      _isLoading = true;
    });

    final result = await fetchBills(context);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final billsData = result['data'] as List<dynamic>;

        _bills = billsData
            .map((billsJson) => BillsModel.fromJson(billsJson))
            .toList();
        _totalBills = _bills.fold(
          0.0,
          (sum, bills) => sum + (bills.amount ?? 0.0),
        );

        print(_totalBills);
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
    _fetchAllBills();
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
                                    'Total Monthly Bills:',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    " \$ ${_totalBills.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                    'Transactions bills',
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
                      itemCount: _bills.length,
                      itemBuilder: (context, index) {
                        final bills = _bills[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _getCategoryIcon(bills.category ?? ''),
                            title: Text('${bills.category ?? 'N/A'}'),
                            trailing: SizedBox(
                              width: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '+ \$ ${bills.amount ?? 'N/A'}',
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
                                                      income: bills,
                                                    )));
                                      } else if (value == 'Delete') {
                                        final result = await deleteIncome(
                                            context, bills.id);

                                        if (result['success']) {
                                          setState(() {
                                            bills.removeAt(index);
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
                                  builder: (context) => const AddBills()));
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
