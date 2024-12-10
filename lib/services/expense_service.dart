import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/register_service.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchExpenses(BuildContext context) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/expense/');

  try {
    final token = await storage.read(key: 'access_token');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 401) {
      await storage.delete(key: 'access_token');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': 'Failed to load expenses.'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to load expenses. $e'};
  }
}

Future<Map<String, dynamic>> addExpenses(BuildContext context, int amount,
    String category, String description, DateTime dateSpended) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/expense/');

  try {
    final requestBody = {
      'amount': amount,
      'category': category,
      'description': description,
      'date_spended': dateSpended.toIso8601String()
    };

    print("Request body: ${json.encode(requestBody)}");

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
      fetchExpenses(context);
      return {'success': true, 'message': 'Successfully added income'};
    } else {
      return {'success': false, 'message': 'Failed to add income'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to add income $e'};
  }
}

Future<Map<String, dynamic>> editExpense(
    BuildContext context,
    int id,
    int amount,
    String description,
    String category,
    DateTime? dateSpended) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/expense/$id/');

  try {
    final response = await http.put(url,
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'category': category,
          'date_spended': dateSpended?.toIso8601String()
        }));
    print(jsonEncode({
      'amount': amount,
      'description': description,
      'category': category,
      'date_spended': dateSpended?.toIso8601String() ?? ''
    }));

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Successfully edited expense'};
    } else {
      final errorMessage =
          jsonDecode(response.body)['message'] ?? 'Error occured';
      return {'success': false, 'message': errorMessage};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to connect to server $e'};
  }
}

Future<Map<String, dynamic>> deleteExpense(BuildContext context, int id) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/expense/$id/');

  try {
    final response = await http.delete(url, headers: {
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

    if (response.statusCode == 204) {
      return {'success': true, 'message': 'Income deleted successfully'};
    } else {
      return {'success': false, 'message': 'Failed to delete income'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to delete income $e'};
  }
}
