import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/services/register_service.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchAllIncomes(BuildContext context) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/income/');

  try {
    final token = await storage.read(key: 'access_token');
    // print(token);

    if (token == null) {
      return {'success': false, 'message': 'No token found'};
    }

    final response = await http.get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 401) {
      await storage.delete(key: 'access_token');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return {'success': false, 'message': 'Invalid token'};
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print(data);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': 'Failed to fetch data'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to fetch Incomes'};
  }
}

Future<Map<String, dynamic>> addIncome(BuildContext context, int amount,
    String description, String category, DateTime dateReceived) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/income/');

  if (token == null) {
    return {'success': false, 'message': "No token found"};
  }

  try {
    final requestBody = {
      'amount': amount,
      'category': category,
      'description': description,
      'date_received': dateReceived.toIso8601String(), // Include full date-time
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
      fetchAllIncomes(context);
      return {'success': true, 'message': 'Successfully added income'};
    } else {
      return {'success': false, 'message': 'Failed to add income'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to add income $e'};
  }
}

Future<Map<String, dynamic>> editIncome(
    BuildContext context,
    int incomeId,
    int amount,
    String description,
    String category,
    DateTime? dateReceived) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/income/$incomeId/');

  try {
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'category': category,
          'date_received': dateReceived?.toIso8601String(),
        }));

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Successfully updated income'};
    } else {
      final errorMessage =
          jsonDecode(response.body)['message'] ?? 'Error occured';
      return {'success': false, 'message': errorMessage};
    }
  } catch (e) {
    return {'success': false, 'message': 'Failed to connect to the server'};
  }
}

Future<Map<String, dynamic>> deleteIncome(
    BuildContext context, int incomeId) async {
  final token = await storage.read(key: 'access_token');
  final url = Uri.parse('http://10.0.2.2:8000/api/income/$incomeId/');

  if (token == null) {
    return {'success': false, 'message': "No token found"};
  }

  try {
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
