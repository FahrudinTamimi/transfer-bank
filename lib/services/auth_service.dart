import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const String baseUrl = 'http://13.215.101.79/api';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Simpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Simpan user info (json string)
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: 'user', value: jsonEncode(user));
  }

  // Ambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Ambil user info
  static Future<Map<String, dynamic>?> getUser() async {
    final userStr = await _storage.read(key: 'user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  // Ambil nama user
  static Future<String?> getUserName() async {
    final user = await getUser();
    return user?['name'];
  }

  // Hapus semua data login (logout)
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // LOGIN
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login URL: $url');
    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user']; // asumsi ada

      if (token != null) {
        await saveToken(token);
        if (user != null) {
          await saveUser(user);
        }
        return true;
      }
    }

    return false;
  }

  // REGISTER
  static Future<bool> register(String email, String name, String password, String passwordConfirmation) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    print('Register URL: $url');
    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
