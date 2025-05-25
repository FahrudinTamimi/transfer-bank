import 'package:flutter/material.dart';
import 'package:transfer_bank/widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class Tutorialpage extends StatelessWidget {
  const Tutorialpage({super.key});

  Widget buildStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade400,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langkah $step: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTutorialSection({
    required String title,
    required List<Map<String, dynamic>> steps,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      children: [
        const SizedBox(height: 8),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          return buildStep(
            step: index + 1,
            title: step['title'],
            description: step['desc'],
            icon: step['icon'],
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Bar(title: 'Tutorial Penggunaan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildTutorialSection(
            title: 'Cara Top Up',
            steps: [
              {'title': 'Buka Aplikasi', 'desc': 'Pastikan Anda sudah login ke dalam aplikasi.', 'icon': Icons.phone_android},
              {'title': 'Pilih Menu Top Up', 'desc': 'Klik menu "Top Up" di halaman utama.', 'icon': Icons.account_balance_wallet},
              {'title': 'Pilih Metode Pembayaran', 'desc': 'Transfer bank atau e-wallet.', 'icon': Icons.payment},
              {'title': 'Masukkan Nominal', 'desc': 'Tentukan jumlah top up.', 'icon': Icons.attach_money},
              {'title': 'Konfirmasi dan Bayar', 'desc': 'Selesaikan proses pembayaran.', 'icon': Icons.check_circle},
            ],
          ),
          buildTutorialSection(
            title: 'Cara Transfer',
            steps: [
              {'title': 'Buka Aplikasi', 'desc': 'Pastikan Anda sudah login ke dalam aplikasi.', 'icon': Icons.phone_android},
              {'title': 'Pilih Menu Transfer', 'desc': 'Klik menu transfer dana.', 'icon': Icons.account_balance_wallet_outlined},
              {'title': 'Masukkan Nomor Tujuan', 'desc': 'Isi rekening penerima.', 'icon': Icons.person},
              {'title': 'Masukkan Nominal', 'desc': 'Tentukan jumlah uang yang ditransfer.', 'icon': Icons.attach_money},
              {'title': 'Konfirmasi dan Kirim', 'desc': 'Periksa kembali dan tekan kirim.', 'icon': Icons.check_circle},
            ],
          ),
          buildTutorialSection(
          title: 'Cara Menghubungi Admin',
          steps: [
              {'title': 'Buka Aplikasi','desc': 'Pastikan Anda sudah login ke dalam aplikasi.','icon': Icons.phone_android},
              {'title': 'Pilih Menu Support','desc': 'Pada halaman utama atau menu navigasi bawah, pilih "Support".','icon': Icons.support_agent},
              {'title': 'Pilih Metode Kontak','desc': 'Anda bisa memilih kontak melalui WhatsApp, Email, Telepon, atau Telegram.','icon': Icons.contact_phone},
              {'title': 'Kirim Pesan ke Admin','desc': 'Klik salah satu metode, lalu kirim pesan sesuai kebutuhan Anda. Admin akan merespons secepatnya.','icon': Icons.message},
          ],
        ),

        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
