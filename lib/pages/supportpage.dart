import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transfer_bank/widgets/bar.dart';
import 'package:transfer_bank/widgets/bottombar.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Gagal membuka link: $url');
    }
  }

  Widget buildSupportItem(String label, IconData icon, Color color, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: () => openLink(url),
          leading: Icon(icon, color: Colors.white, size: 30),
          title: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Bar(title: 'Support'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              children: [
                buildSupportItem(
                  'Email',
                  Icons.email,
                  Colors.blue.shade400,
                  'mailto:lutfizadeh5@gmail.com',
                ),
                buildSupportItem(
                  'WhatsApp',
                  Icons.chat,
                  Colors.green,
                  'https://wa.me/6285156817148',
                ),
                buildSupportItem(
                  'Telepon',
                  Icons.phone,
                  Colors.orange,
                  'tel:+62851568171488',
                ),
                buildSupportItem(
                  'Telegram',
                  Icons.send,
                  Colors.blue.shade700,
                  'https://t.me/Lutfizadeh',
                ),
              ],
            ),
          ),

          // Footer kecil di bawah list
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              'Butuh bantuan lebih lanjut? Hubungi kami kapan saja!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomBar(),
    );
  }
}
