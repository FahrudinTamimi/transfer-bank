import 'package:flutter/material.dart';
import 'package:transfer_bank/pages/historypage.dart';
import 'package:transfer_bank/pages/homepage.dart';
import 'package:transfer_bank/pages/supportpage.dart';
import 'package:transfer_bank/pages/profilepage.dart';
import 'package:transfer_bank/pages/topuppage.dart';
import 'package:transfer_bank/pages/tutorialpage.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
  });

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
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              }),
            IconButton(icon: Icon(Icons.history), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
            }),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[300],
              ),
              width: 60,
              height: 60,
              child: IconButton(icon: Icon(Icons.add), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TopupPage()));
              }),
            ),
            IconButton(icon: Icon(Icons.phone), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SupportPage()));
            }),
            IconButton(icon: Icon(Icons.person), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            }),
            IconButton(icon: Icon(Icons.info), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Tutorialpage()));
            }),
          ],
        ),
      ),
    );
  }
}