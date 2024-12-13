import 'dart:convert';
import 'package:flutter_expense_tracker/services/register_service.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final url = Uri.parse("http://10.0.2.2:8000/api/token/");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String accessToken = responseData['access'];
      String refreshToken = responseData['refresh'];

      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);

      final data = json.decode(response.body);
      final token = data['token'];

      await storage.write(key: 'auth_token', value: token);
      return {'success': true, 'message': 'Login Successful'};
    } else {
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData.toString()};
    }
  } catch (e) {
    return {'success': false, 'message': 'Error: $e'};
  }
}
