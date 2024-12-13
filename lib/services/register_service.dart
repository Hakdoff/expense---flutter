import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await storage.write(key: 'access_token', value: token);
}

Future<Map<String, dynamic>> registerUser(
    String email, String username, String password, String password2) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/register/');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
        'password2': password2
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'User registered successfully'};
    } else {
      // Parse error messages from backend
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData.toString()};
    }
  } catch (e) {
    return {'success': false, 'message': 'Registration failed: $e'};
  }
}
