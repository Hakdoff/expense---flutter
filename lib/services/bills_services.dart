import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/register_service.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchBills(BuildContext context) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/bills/');

  try {
    final token = await storage.read(key: 'access_token');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 401) {
      await storage.delete(key: 'access_token');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return {'success': false, 'message': 'Invalid token'};
    }

    if (response.statusCode == 400) {
      print('Error Response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': 'Failed to fetch data'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to fetch Incomes'};
  }
}

Future<Map<String, dynamic>> addBills(
    BuildContext context, int amount, String category, String item) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/bills/');

  try {
    final requestBody = {
      'amount': amount,
      'item': item,
      'category': category,
      'due_date': DateTime.now().toIso8601String(),
    };
    print(requestBody);

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(requestBody));

    if (response.statusCode == 401) {
      await storage.delete(key: 'access_token');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return {'success': false, 'message': 'Invalid token'};
    }

    if (response.statusCode == 201) {
      fetchBills(context);
      return {'success': true, 'message': 'Successfully added income'};
    } else {
      return {'success': false, 'message': 'Failed to add income'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to add income $e'};
  }
}
