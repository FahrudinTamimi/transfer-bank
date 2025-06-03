import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/bar.dart';
import '../widgets/bottombar.dart';
import '../services/auth_service.dart';

class Bank {
  final int id;
  final String bankCode;
  final String bankName;

  Bank({required this.id, required this.bankCode, required this.bankName});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      bankCode: json['bank_code'],
      bankName: json['bank_name'],
    );
  }
}

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<Bank> banks = [];
  List<Bank> filteredBanks = [];
  Bank? selectedBank;

  final TextEditingController _bankSearchController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;
  bool isCheckingAccount = false;
  String? validationMessage;

  final String apiKey = dotenv.env['API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchBanks();
    _bankSearchController.addListener(_filterBanks);
    _accountController.addListener(_onAccountChanged);
  }

  @override
  void dispose() {
    _bankSearchController.dispose();
    _accountController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchBanks() async {
    final url = Uri.parse('http://13.215.101.79/api/banks?per_page=188');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        setState(() {
          banks = list.map((e) => Bank.fromJson(e)).toList();
          filteredBanks = banks;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data bank: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengambil bank: $e')),
      );
    }
  }

  void _filterBanks() {
    final query = _bankSearchController.text.toLowerCase();
    setState(() {
      filteredBanks = banks
          .where((bank) =>
              bank.bankName.toLowerCase().contains(query) ||
              bank.bankCode.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onAccountChanged() {
    if (selectedBank != null && _accountController.text.length >= 6) {
      cekRekening(selectedBank!.bankCode, _accountController.text.trim());
    } else {
      setState(() {
        _nameController.text = '';
        validationMessage = null;
      });
    }
  }

  Future<void> cekRekening(String bankCode, String accountNumber) async {
    setState(() {
      isCheckingAccount = true;
      validationMessage = null;
    });

    final url = Uri.parse('https://atlantich2h.com/transfer/cek_rekening');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'api_key': apiKey,
          'bank_code': bankCode,
          'account_number': accountNumber,
        },
      );

      print('CekRekening Response status: ${response.statusCode}');
      print('CekRekening Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        final ownerName = data['data']?['nama_pemilik'];

        if (status == true && ownerName != null && ownerName.isNotEmpty) {
          setState(() {
            _nameController.text = ownerName;
            validationMessage = 'Berhasil mendapatkan nama rekening';
          });
        } else {
          setState(() {
            _nameController.text = '';
            validationMessage = 'Nama rekening tidak ditemukan';
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = '';
          validationMessage = 'Gagal memeriksa nama rekening: ${data['message'] ?? 'Error tidak diketahui'}';
        });
      }
    } catch (e) {
      print('CekRekening Error: $e');
      setState(() {
        _nameController.text = '';
        validationMessage = 'Terjadi kesalahan jaringan saat cek rekening';
      });
    } finally {
      setState(() {
        isCheckingAccount = false;
      });
    }
  }

  Future<void> submitTransfer() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank terlebih dahulu')),
      );
      return;
    }

    final accountNumber = _accountController.text.trim();
    final accountName = _nameController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());
    final description = _descriptionController.text.trim();

    print('SubmitTransfer Debug: account=$accountNumber, name=$accountName, amount=$amount');

    if (accountNumber.isEmpty || accountName.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dengan benar')),
      );
      return;
    }

    setState(() => isLoading = true);

    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Harap login ulang.')),
      );
      setState(() => isLoading = false);
      return;
    }

    final refId = DateTime.now().millisecondsSinceEpoch.toString();
   final now = DateTime.now();
    final formattedDate =
    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
    "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final bodyData = {
      "ref_id": refId,
      "type": "transfer",
      "bank_id": selectedBank!.id,
      "account_number": accountNumber,
      "account_name": accountName,
      "amount": amount,
      "description": description,
      "date": formattedDate,
      "status": "Pending",
    };

    print('SubmitTransfer Body: $bodyData');

    try {
      final response = await http.post(
        Uri.parse('http://13.215.101.79/api/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      print('SubmitTransfer Response status: ${response.statusCode}');
      print('SubmitTransfer Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer berhasil')),
        );
        _bankSearchController.clear();
        _accountController.clear();
        _nameController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          selectedBank = null;
          filteredBanks = banks;
          validationMessage = null;
        });
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal transfer: ${data['message'] ?? 'Terjadi kesalahan'}')),
        );
      }
    } catch (e) {
      print('SubmitTransfer Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Bar(title: 'Transfer'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Bank:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _bankSearchController,
                decoration: InputDecoration(
                  hintText: 'Cari bank...',
                  suffixIcon: selectedBank != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedBank = null;
                              _bankSearchController.clear();
                              filteredBanks = banks;
                              _nameController.clear();
                              validationMessage = null;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              if (filteredBanks.isNotEmpty && selectedBank == null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredBanks.length,
                    itemBuilder: (context, index) {
                      final bank = filteredBanks[index];
                      return ListTile(
                        title: Text(bank.bankName),
                        subtitle: Text(bank.bankCode),
                        onTap: () {
                          setState(() {
                            selectedBank = bank;
                            _bankSearchController.text = bank.bankName;
                            filteredBanks = [];
                            _nameController.clear();
                            validationMessage = null;
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Nama Pemilik Rekening',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  suffixIcon: isCheckingAccount
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
              if (validationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    validationMessage!,
                    style: TextStyle(
                      color: validationMessage == 'Berhasil mendapatkan nama rekening'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  labelText: 'Nominal Transfer',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : submitTransfer,
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    isLoading ? 'Memproses...' : 'Kirim Transfer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
