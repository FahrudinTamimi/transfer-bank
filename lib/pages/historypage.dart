import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Contoh data dummy transaksi
  final List<Map<String, dynamic>> transactions = const [
    {
      'title': 'Top Up via BNI',
      'subtitle': '01 Mei 2025 - 09:30',
      'amount': 250000,
      'type': 'topup'
    },
    {
      'title': 'Top Up via Mandiri',
      'subtitle': '02 Mei 2025 - 11:15',
      'amount': 500000,
      'type': 'topup'
    },
    {
      'title': 'Transfer ke BCA',
      'subtitle': '03 Mei 2025 - 13:45',
      'amount': 100000,
      'type': 'transfer'
    },
    {
      'title': 'Transfer ke BRI',
      'subtitle': '05 Mei 2025 - 18:20',
      'amount': 200000,
      'type': 'transfer'
    },
  ];

  int getTotal(String type) {
    return transactions
        .where((tx) => tx['type'] == type)
        .fold(0, (sum, tx) => sum + tx['amount'] as int);
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
          boxShadow: [
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
                  'Rp${totalIn.toString()}',
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
                  'Rp${totalOut.toString()}',
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

    return ListTile(
      tileColor: isTopUp ? Colors.green[50] : Colors.red[50],
      leading: CircleAvatar(
        backgroundColor: isTopUp ? Colors.green : Colors.red,
        child: Icon(
          isTopUp ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
        ),
      ),
      title: Text(
        tx['title'],
        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        tx['subtitle'],
        style: const TextStyle(fontFamily: 'Poppins'),
      ),
      trailing: Text(
        '${isTopUp ? '+' : '-'} Rp${tx['amount']}',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isTopUp ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topUpTransactions = transactions.where((tx) => tx['type'] == 'topup').toList();
    final transferTransactions = transactions.where((tx) => tx['type'] == 'transfer').toList();

    return Scaffold(
      appBar: const Bar(title: 'History'),
      body: ListView(
        children: [
          buildMonthlySummary(),
          buildSectionTitle('Uang Masuk (Top Up)'),
          ...topUpTransactions.map(buildHistoryItem).toList(),
          buildSectionTitle('Uang Keluar (Transfer Bank)'),
          ...transferTransactions.map(buildHistoryItem).toList(),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
