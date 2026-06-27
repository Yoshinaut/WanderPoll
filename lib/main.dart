import 'package:flutter/material.dart';
import 'package:wonder_poll/pages/home.dart';
import 'package:wonder_poll/pages/profile.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(

      navigationBarTheme: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        // Color when the navigation tab is selected
            if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFad2a2a), size: 24);}
        // Color when the navigation tab is unselected
            return const IconThemeData(color: Colors.white, size: 20);
        }),
      ),

      fontFamily:'Poppins'),

      home: const LoginScreen(
      ),
    );
  }
}
