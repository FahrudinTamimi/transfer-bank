import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/bar.dart';
import '../widgets/bottombar.dart';
import '../services/auth_service.dart';
import 'topuppage.dart';
import 'transferpage.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({Key? key, this.token = ''}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalTopup = 0;
  int totalTransfer = 0;
  int currentBalance = 0;
  String? userName;
  String? token;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final fetchedToken =
          widget.token.isNotEmpty ? widget.token : await AuthService.getToken();

      if (fetchedToken == null || fetchedToken.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Token tidak ditemukan.';
        });
        return;
      }

      setState(() {
        token = fetchedToken;
      });

      await Future.wait([fetchProfile(), fetchTransactionsSummary()]);
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('http://13.215.101.79/api/profile');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userName = data['data']['name'];
      });
    }
  }

  Future<void> fetchTransactionsSummary() async {
    final url = Uri.parse('http://13.215.101.79/api/transactions');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final transactions = data['data'] as List;

      int totalIn = 0;
      int totalOut = 0;
      for (var tx in transactions) {
        int amount = int.tryParse(tx['amount'].toString()) ?? 0;
        if (tx['type'] == 'topup') {
          totalIn += amount;
        } else if (tx['type'] == 'transfer') {
          totalOut += amount;
        }
      }

      setState(() {
        totalTopup = totalIn;
        totalTransfer = totalOut;
        currentBalance = totalIn - totalOut;
        isLoading = false;
      });
    }
  }

  String formatCurrency(int amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  void handleTopup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopUpPage()),
    );
  }

  void handleTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransferPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Bar(title: 'Home'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Selamat datang, ${userName ?? 'Pengguna'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo Saat Ini',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency(currentBalance),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Top Up',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                Text(
                                  formatCurrency(totalTopup),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Transfer',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                Text(
                                  formatCurrency(totalTransfer),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Tombol Topup dan Transfer
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: handleTopup,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: Colors.blue[100],
                                      child: SizedBox(
                                        height: 90,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add_circle_outline,
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Topup',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: handleTransfer,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: Colors.blue[100],
                                      child: SizedBox(
                                        height: 90,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.send_outlined,
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Transfer',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}