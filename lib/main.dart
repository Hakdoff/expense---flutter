import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/landing_page.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:flutter_expense_tracker/views/expense/expense_page.dart';
import 'package:flutter_expense_tracker/views/home_page.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Future<String?> _getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'access_token');
  }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: _getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Expense Tracker"),
                  actions: [
                    IconButton(
                        onPressed: () => logout(context),
                        icon: const Icon(Icons.logout))
                  ],
                ),
                body: const HomePage());
          } else {
            return const LandingPage();
          }
        },
      ),
    );
  }
}
