import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://13.215.101.79/api';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Simpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Simpan user info (misal: nama, email, dsb)
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

  // Hapus semua data login
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Login dan simpan token + data user
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

  print('URL: $url');
  print('STATUS CODE: ${response.statusCode}');
  print('RESPONSE BODY: ${response.body}');

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(response.body);
    final token = data['token'];

    if (token != null) {
      await saveToken(token);

      // Kalau tidak ada user info di response, skip saveUser()
      // atau tambahkan dummy user data sesuai kebutuhan
      return true;
    }
  }

  return false;
}
}