import 'package:flutter/material.dart';

class Bar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Bar({
    super.key,
    required this.title
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blue[300],
      centerTitle: true,
    );
  }
}