import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  TextEditingController _nominalController = TextEditingController();
  List<dynamic> banks = [];
  List<dynamic> filteredBanks = [];
  int? selectedBankId;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  Future<void> fetchBanks() async {
    final response = await http.get(Uri.parse('http://13.215.101.79/api/banks'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      setState(() {
        banks = data;
        filteredBanks = data;
      });
    } else {
      print('Gagal ambil data bank');
    }
  }

  void filterBanks(String query) {
    setState(() {
      searchQuery = query;
      filteredBanks = banks
          .where((bank) =>
              bank['bank_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> submitTopup() async {
    final amount = int.tryParse(_nominalController.text);
    if (selectedBankId == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank dan isi nominal yang valid')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://13.215.101.79/api/transaksi'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "type": "topup",
        "bank_id": selectedBankId,
        "amount": amount,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Top up berhasil')),
      );
      _nominalController.clear();
      setState(() {
        selectedBankId = null;
      });
    } else {
      print('Response gagal topup: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal melakukan top up')),
      );
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Bar(title: 'Topup'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Nominal
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                labelText: 'Nominal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Bank
            TextField(
              onChanged: filterBanks,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_balance),
                hintText: 'Cari bank...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Bank (pilih salah satu)
            Expanded(
              child: filteredBanks.isEmpty
                  ? const Center(child: Text('Bank tidak ditemukan'))
                  : ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        final isSelected = selectedBankId == bank['id'];
                        return ListTile(
                          leading: Icon(Icons.account_balance_wallet,
                              color: isSelected ? Colors.blue : Colors.grey),
                          title: Text(
                            bank['bank_name'],
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.blue)
                              : null,
                          tileColor: isSelected ? Colors.blue[50] : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            setState(() {
                              selectedBankId = bank['id'];
                            });
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),
            // Tombol Topup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: submitTopup,
                icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.white),
                label: const Text(
                  'Topup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
