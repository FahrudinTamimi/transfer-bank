import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> banks = [];
  List<dynamic> filteredBanks = [];
  int? selectedBankId;

  @override
  void initState() {
    super.initState();
    fetchBanks();
    _searchController.addListener(_filterBanks);
  }

  Future<void> fetchBanks() async {
    final response = await http.get(Uri.parse('http://13.215.101.79/api/banks'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        banks = responseData['data'];
        filteredBanks = banks;
      });
    } else {
      print('Gagal ambil data bank');
    }
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredBanks = banks;
      });
    } else {
      setState(() {
        filteredBanks = banks.where((bank) {
          final name = bank['bank_name'].toString().toLowerCase();
          return name.contains(query);
        }).toList();
      });
    }
  }

  Future<void> submitTransfer() async {
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
        "type": "transfer",
        "bank_id": selectedBankId,
        "amount": amount,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer berhasil')),
      );
      _nominalController.clear();
      _searchController.clear();
      setState(() {
        selectedBankId = null;
        filteredBanks = banks;
      });
    } else {
      print('Gagal transfer: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal melakukan transfer')),
      );
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Bar(title: 'Transfer'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Nominal dengan ikon uang
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

            const SizedBox(height: 20),

            // Pencarian Bank dengan ikon bank
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance),
                labelText: 'Cari Bank Tujuan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Daftar Bank dengan ikon wallet dan highlight pilihan
            Expanded(
              child: filteredBanks.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        final isSelected = selectedBankId == bank['id'];

                        return ListTile(
                          leading: Icon(
                            Icons.account_balance_wallet,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            bank['bank_name'],
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          tileColor: isSelected ? Colors.blue[50] : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.blue)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            setState(() {
                              selectedBankId = bank['id'];
                              _searchController.text = bank['bank_name'];
                              FocusScope.of(context).unfocus();
                            });
                          },
                        );
                      },
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Bank tidak ditemukan'),
                    ),
            ),
            const SizedBox(height: 16),

            // Tombol Transfer dengan ikon kirim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: submitTransfer,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Transfer',
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
