import 'package:flutter/material.dart';
import 'package:transfer_bank/pages/historypage.dart';
import 'package:transfer_bank/pages/homepage.dart';
import 'package:transfer_bank/pages/supportpage.dart';
import 'package:transfer_bank/pages/profilepage.dart';
import 'package:transfer_bank/pages/topuppage.dart';
import 'package:transfer_bank/pages/tutorialpage.dart';
import 'package:transfer_bank/pages/login.dart';
import 'package:transfer_bank/services/auth_service.dart'; // pastikan import AuthService

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final storedToken = await AuthService.getToken();
    setState(() {
      token = storedToken;
    });
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.blue[100],
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                if (token != null && token!.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryPage(token: token!)),
                  );
                } else {
                  _goToLogin(context);
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[300],
              ),
              width: 60,
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TopUpPage()),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportPage()),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(Icons.person),
            //   onPressed: () {
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(builder: (_) => const ProfilePage()),
            //     );
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tutorialpage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
