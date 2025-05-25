import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://13.215.101.79/api';

  static Future<List<dynamic>> getBanks() async {
    final response = await http.get(Uri.parse('$baseUrl/banks'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data']; // Mengambil list bank dari key 'data'
    } else {
      throw Exception('Gagal memuat data bank');
    }
  }

  static Future<bool> transfer(String bankCode, int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transfer'),
      body: {
        'bank_code': bankCode,
        'amount': amount.toString(),
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> topUp(int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topup'),
      body: {
        'amount': amount.toString(),
      },
    );
    return response.statusCode == 200;
  }
}
