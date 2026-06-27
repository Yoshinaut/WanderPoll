import 'package:flutter/material.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Feed',
      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: (FontWeight(700)))),
    );
  }
}