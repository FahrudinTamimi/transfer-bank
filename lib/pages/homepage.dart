import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../widgets/bar.dart';
import '../widgets/bottombar.dart';
import 'login.dart';
import 'topuppage.dart';
import 'transferpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List<dynamic> banks = [];
  List<dynamic> filteredBanks = [];
  String searchQuery = '';
  int saldo = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Ambil token, kalau tidak ada langsung logout
      final token = await storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _logoutAndRedirect();
        return;
      }

      // Ambil daftar bank dari API
      final banksData = await ApiService.getBanks();

      // Ambil saldo user dari API
      final currentSaldo = await ApiService.getSaldo();

      setState(() {
        banks = banksData;
        filteredBanks = banksData;
        saldo = currentSaldo;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (e.toString().contains('401')) {
        // Token expired atau unauthorized, logout
        _logoutAndRedirect();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterBanks(String query) {
    setState(() {
      searchQuery = query;
      filteredBanks = banks.where((bank) {
        final name = bank['bank_name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _logoutAndRedirect() async {
    await storage.delete(key: 'token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void handleTopUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopupPage()),
    );
  }

  void handleTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransferPage()),
    );
  }

  void handleLogout() {
    _logoutAndRedirect();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: Bar(
        title: 'Home',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Saldo Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.blue[300],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo User',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rp. $saldo',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Topup & Transfer
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: handleTopUp,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue[100],
                      child: SizedBox(
                        height: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_circle_outline, size: 30, color: Colors.blue),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue[100],
                      child: SizedBox(
                        height: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send_outlined, size: 30, color: Colors.blue),
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
            const SizedBox(height: 20),

            // Search Field
            TextField(
              onChanged: filterBanks,
              decoration: InputDecoration(
                hintText: 'Cari bank...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Bank
            Expanded(
              child: filteredBanks.isEmpty
                  ? const Center(child: Text('Bank tidak ditemukan'))
                  : ListView.separated(
                      itemCount: filteredBanks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        return ListTile(
                          leading: Icon(
                            bank['type'] == "bank"
                                ? Icons.account_balance_outlined
                                : Icons.account_balance_wallet,
                            color: Colors.blue,
                          ),
                          title: Text(
                            bank['bank_name'],
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(
                            'Kode: ${bank['bank_code']}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
