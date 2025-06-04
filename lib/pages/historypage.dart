import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/bar.dart';
import '../widgets/bottombar.dart';
import '../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  final String token;
  const HistoryPage({Key? key, this.token = ''}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> transactions = [];
  Map<String, String> bankNames = {}; // Map untuk menyimpan bank_id -> bank_name
  bool isLoading = true;
  String errorMessage = '';
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    print('===> Mulai loadToken() di HistoryPage...');
    print('widget.token: ${widget.token}');

    try {
      final fetchedToken =
          widget.token.isNotEmpty ? widget.token : await AuthService.getToken();

      print('Token yang akan digunakan: $fetchedToken');

      if (fetchedToken == null || fetchedToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token tidak ditemukan. Harap login ulang.')),
          );
          setState(() {
            isLoading = false;
            errorMessage = 'Token kosong atau null';
          });
          // Redirect ke login setelah delay singkat supaya Snackbar terlihat
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
        return;
      }

      setState(() {
        token = fetchedToken;
      });

      // Fetch banks first, then transactions
      await fetchBanks();
      await fetchTransactions();
    } catch (e, stackTrace) {
      print('Error saat loadToken(): $e');
      print(stackTrace);
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat token: $e';
        });
      }
    }
  }

  Future<void> fetchBanks() async {
    if (token == null || token!.isEmpty) {
      return;
    }

    final url = Uri.parse('http://13.215.101.79/api/banks?per_page=187');
    print('Memulai fetchBanks() ke $url dengan token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Banks API Status code: ${response.statusCode}');
      print('Banks API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final banks = data['data'] ?? [];
        
        // Create map of bank_id -> bank_name
        Map<String, String> tempBankNames = {};
        for (var bank in banks) {
          tempBankNames[bank['id'].toString()] = bank['bank_name'] ?? 'Unknown Bank';
        }
        
        setState(() {
          bankNames = tempBankNames;
        });
        
        print('Berhasil memuat ${banks.length} bank');
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi habis, silakan login ulang.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('Error fetching banks: ${response.statusCode}');
        print('Error Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error saat fetchBanks(): $e');
      print(stackTrace);
    }
  }

  Future<void> fetchTransactions() async {
    if (token == null || token!.isEmpty) {
      setState(() {
        errorMessage = 'Token tidak ditemukan.';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://13.215.101.79/api/transactions');
    print('Memulai fetchTransactions() ke $url dengan token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['data'] ?? [];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired atau tidak valid, arahkan ke login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi habis, silakan login ulang.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('Error Body: ${response.body}');
        setState(() {
          errorMessage = 'Gagal mengambil data transaksi: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error saat fetchTransactions(): $e');
      print(stackTrace);
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  int getTotal(String type) {
    return transactions
        .where((tx) => tx['type'] == type)
        .fold(0, (sum, tx) => sum + (tx['amount'] as int));
  }

  String formatCurrency(int amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  String getBankName(dynamic bankId) {
    if (bankId == null) return 'Unknown Bank';
    String bankIdStr = bankId.toString();
    return bankNames[bankIdStr] ?? 'Bank ID: $bankIdStr';
  }

  Widget buildMonthlySummary() {
    int totalIn = getTotal('topup');
    int totalOut = getTotal('transfer');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Uang Masuk', style: TextStyle(fontFamily: 'Poppins')),
                Text(
                  formatCurrency(totalIn),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Uang Keluar', style: TextStyle(fontFamily: 'Poppins')),
                Text(
                  formatCurrency(totalOut),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget buildHistoryItem(Map<String, dynamic> tx) {
    bool isTopUp = tx['type'] == 'topup';

    String dateFormatted = '';
    try {
      // Parse ISO 8601 format: "2025-05-25T20:16:19.000000Z"
      final dateTime = DateTime.parse(tx['created_at']);
      // Convert to local timezone
      final localDateTime = dateTime.toLocal();
      dateFormatted = DateFormat('dd MMM yyyy - HH:mm', 'id_ID').format(localDateTime);
    } catch (e) {
      print('Error parsing date: $e');
      print('Original created_at: ${tx['created_at']}');
      dateFormatted = tx['created_at']?.toString() ?? 'Invalid Date';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTopUp ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTopUp ? Colors.green : Colors.red,
          child: Icon(
            isTopUp ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(
          tx['title'] ?? (isTopUp ? 'Top Up' : 'Transfer'),
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatted,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            if (tx['account_number'] != null)
              Text(
                'Rekening: ${tx['account_number']}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
            if (tx['account_name'] != null)
              Text(
                'Nama: ${tx['account_name']}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
            if (tx['description'] != null)
              Text(
                'Keterangan: ${tx['description']}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
            if (tx['status'] != null)
              Text(
                'Status: ${tx['status']}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isTopUp ? '+' : '-'} ${formatCurrency(tx['amount'] ?? 0)}',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isTopUp ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              getBankName(tx['bank_id']),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isTopUp ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort transactions by created_at (newest first)
    final sortedTransactions = List.from(transactions);
    sortedTransactions.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        return dateB.compareTo(dateA); // Descending order (newest first)
      } catch (e) {
        print('Error sorting dates: $e');
        return 0;
      }
    });

    final topUpTransactions =
        sortedTransactions.where((tx) => tx['type'] == 'topup').toList();
    final transferTransactions =
        sortedTransactions.where((tx) => tx['type'] == 'transfer').toList();

    return Scaffold(
      appBar: const Bar(title: 'History'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView(
                  children: [
                    buildMonthlySummary(),
                    buildSectionTitle('Uang Masuk (Top Up)'),
                    ...topUpTransactions.map(
                        (tx) => buildHistoryItem(tx as Map<String, dynamic>)),
                    buildSectionTitle('Uang Keluar (Transfer Bank)'),
                    ...transferTransactions.map(
                        (tx) => buildHistoryItem(tx as Map<String, dynamic>)),
                  ],
                ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}