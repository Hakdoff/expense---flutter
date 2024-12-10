import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:flutter_expense_tracker/views/expense/expense_page.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    const storage = FlutterSecureStorage();

    try {
      // Delete the token
      await storage.delete(key: 'access_token');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to logout")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("All Incomes"),
          ),
          leading: Container(),
          actions: [
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.logout))
          ],
        ),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExpensePage()),
                  );
                },
                child: const Text("Expense")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IncomePage()),
                  );
                },
                child: const Text("Income"))
          ],
        ));
  }
}
