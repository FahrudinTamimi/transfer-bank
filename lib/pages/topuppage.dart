import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api_service.dart';
import '../widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  List<dynamic> banks = [];
  List<dynamic> filteredBanks = [];
  int? selectedBankId;
  String searchQuery = '';
  bool searchingAccount = false;

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  // Ambil data bank dari API
  Future<void> fetchBanks() async {
    final response = await http.get(Uri.parse('http://13.215.101.79/api/banks?per_page=188'));
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

  // Filter bank berdasar pencarian
  void filterBanks(String query) {
    setState(() {
      searchQuery = query;
      filteredBanks = banks.where((bank) {
        final bankName = bank['bank_name']?.toString().toLowerCase() ?? '';
        return bankName.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Cari nama rekening berdasarkan nomor rekening dengan POST ke API
  Future<Map<String, dynamic>?> searchAccountNumber(String accountNumber) async {
    setState(() {
      searchingAccount = true;
    });

    final token = await ApiService.getToken();
    final url = Uri.parse('http://13.215.101.79/api/accounts/search');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "account_number": accountNumber,
      }),
    );

    setState(() {
      searchingAccount = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }
    }
    return null;
  }

  // Saat input nomor rekening dikirim (enter/done)
  Future<void> onAccountNumberSubmitted(String value) async {
    if (value.trim().isEmpty) return;

    final result = await searchAccountNumber(value.trim());
    if (result != null) {
      setState(() {
        _accountNameController.text = result['account_name'] ?? '';

        // Sesuaikan bank berdasar nama bank dari hasil pencarian
        final bankFound = banks.firstWhere(
          (bank) =>
              bank['bank_name']?.toString().toLowerCase() ==
              (result['bank'] ?? '').toLowerCase(),
          orElse: () => null,
        );

        if (bankFound != null) {
          selectedBankId = bankFound['id'];
        } else {
          selectedBankId = null;
        }
      });
    } else {
      setState(() {
        _accountNameController.clear();
        selectedBankId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor rekening tidak ditemukan')),
      );
    }
  }

  // Submit data top up ke backend
  Future<void> submitTopup() async {
    final amount = int.tryParse(_nominalController.text);
    final accountNumber = _accountNumberController.text.trim();
    final accountName = _accountNameController.text.trim();

    if (selectedBankId == null ||
        amount == null ||
        accountNumber.isEmpty ||
        accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua data dengan benar')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://13.215.101.79/api/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "type": "topup",
        "bank_id": selectedBankId,
        "account_number": accountNumber,
        "account_name": accountName,
        "amount": amount,
        "description": "Topup via aplikasi",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Top up berhasil')),
      );
      _nominalController.clear();
      _accountNumberController.clear();
      _accountNameController.clear();
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
    _accountNumberController.dispose();
    _accountNameController.dispose();
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
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nomor Rekening / Wallet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: searchingAccount
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onSubmitted: onAccountNumberSubmitted,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _accountNameController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Nama Pemilik Rekening / Wallet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 16),

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

            TextField(
              onChanged: filterBanks,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance),
                hintText: 'Cari bank / wallet...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredBanks.isEmpty
                  ? const Center(child: Text('Bank atau Wallet tidak ditemukan'))
                  : ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        final isSelected = selectedBankId == bank['id'];
                        return ListTile(
                          leading: Icon(
                            bank['type'] == 'bank'
                                ? Icons.account_balance_outlined
                                : Icons.account_balance_wallet,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            bank['bank_name'] ?? '',
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: submitTopup,
                icon: const Icon(Icons.add_circle_outline,
                    size: 30, color: Colors.white),
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
