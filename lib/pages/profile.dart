import 'dart:io'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wonder_poll/main.dart';
import 'package:wonder_poll/pages/home.dart';

// ==========================================
// HARDCODED CREDENTIALS (No Online Storage)
// ==========================================
const String kHardcodedUsername = "user@email.com";
const String kHardcodedPassword = "password";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile & Login App',
      // Explicitly forcing your custom dark color across the whole app theme
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF222429),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final inputEmail = _emailController.text.trim();
      final inputPassword = _passwordController.text;

      if (inputEmail == kHardcodedUsername && inputPassword == kHardcodedPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Color(0xFFad2a2a)),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 30),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFad2a2a)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFad2a2a)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFad2a2a),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ==========================================
// 2. PROFILE SCREEN
// ==========================================
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? _pickedImage; 
  final ImagePicker _picker = ImagePicker();

  Future<void> _changeProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildProfileImage(),
            const SizedBox(height: 15),
            _buildProfileDetails(),
            const SizedBox(height: 50),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      if (kIsWeb) {
        imageProvider = NetworkImage(_pickedImage!.path);
      } else {
        imageProvider = FileImage(File(_pickedImage!.path));
      }
    } else {
      imageProvider = const AssetImage('assets/images/profileicon.jpg');
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(radius: 60, backgroundImage: imageProvider),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFad2a2a),
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: _changeProfileImage, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return const Column(
      children: [
        Text(
          'Asa Mitaka',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'asa.mitaka@example.com',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(Icons.person, 'Account Settings', () {}, textColor: Colors.white),
          _buildMenuItem(Icons.notifications, 'Notifications', () {}, textColor: Colors.white),
          _buildMenuItem(Icons.security, 'Privacy & Security', () {}, textColor: Colors.white),
          _buildMenuItem(Icons.help, 'Help & Support', () {}, textColor: Colors.white),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey),
          _buildMenuItem(
            Icons.logout, 
            'Logout', 
            _logout, 
            textColor: Colors.red, 
            iconColor: Colors.red
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? textColor, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFFad2a2a)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}