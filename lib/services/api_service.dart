import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://13.215.101.79/api';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Ambil token dari secure storage
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Simpan token ke secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Hapus token dari secure storage
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  // Login user, simpan token jika berhasil
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await saveToken(token);
        return true;
      }
    }
    return false;
  }

  // Logout user (hapus token)
  static Future<void> logout() async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/auth/logout');
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    await deleteToken();
  }

  // Ambil daftar bank
  static Future<List<dynamic>> getBanks() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/banks?per_page=188');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<dynamic>.from(data['data']);
      } else {
        throw Exception('Response API tidak valid: ${response.body}');
      }
    } else {
      throw Exception('Gagal mengambil data bank: ${response.statusCode}');
    }
  }

  // Ambil saldo user
  static Future<int> getSaldo() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/users/saldo');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['saldo'] ?? 0;
    } else {
      throw Exception('Gagal mengambil saldo: ${response.statusCode}');
    }
  }

  // Buat transaksi (topup/transfer)
  static Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/transactions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(transactionData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Gagal membuat transaksi: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}
