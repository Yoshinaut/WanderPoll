import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings',
      style: TextStyle(color: Colors.white, fontSize:  40, fontWeight: (FontWeight(700)))),
    );
  }
}