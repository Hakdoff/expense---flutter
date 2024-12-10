import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/landing_page.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:flutter_expense_tracker/views/home_page.dart';
import 'package:flutter_expense_tracker/views/income/income_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder(
            future: _getToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && snapshot.data != null) {
                return const HomePage();
              } else {
                return const LandingPage();
              }
            }));
  }
}

// Get Token
Future _getToken() async {
  const storage = FlutterSecureStorage();
  try {
    final token = await storage.read(key: 'access_token');
    return token;
  } catch (e) {
    print("error reading token: $e");
    return null;
  }
}
