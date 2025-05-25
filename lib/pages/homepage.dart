import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';
import 'package:transfer_bank/services/api_service.dart';
import 'package:transfer_bank/pages/topuppage.dart'; 
import 'package:transfer_bank/pages/transferpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> bankList = [];

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  void fetchBanks() async {
    try {
      List<dynamic> banks = await ApiService.getBanks();
      setState(() {
        bankList = banks;
      });
    } catch (e) {
      print('Gagal mengambil data: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Bar(title: 'Home'),
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
                  children: const [
                    Text(
                      'Saldo User',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rp. 100.000',
                      style: TextStyle(
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
                            Text('Topup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                )),
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
                            Text('Transfer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daftar Bank
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Bank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: bankList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: bankList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bank = bankList[index];
                        return ListTile(
                          leading: const Icon(Icons.account_balance_outlined, color: Colors.blue),
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
