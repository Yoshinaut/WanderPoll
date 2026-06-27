import 'dart:io'; // Needed for File operations
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the package

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Store the picked image file path here
  XFile? _pickedImage; 
  final ImagePicker _picker = ImagePicker();

  // Function to trigger the image picker
  Future<void> _changeProfileImage() async {
    try {
      // You can change Source to ImageSource.camera if you want to take a new photo
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compresses image slightly for performance
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      // Handle permission denied or other errors here
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 15),
            _buildProfileDetails(),
            const SizedBox(height: 50),
            const SizedBox(height: 30),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    // Determine the ImageProvider based on whether an image was picked or not
    ImageProvider imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(File(_pickedImage!.path));
    } else {
      imageProvider = const AssetImage('assets/images/profileicon.jpg');
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: imageProvider, // Uses dynamic provider
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFad2a2a),
              radius: 14,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: _changeProfileImage, // Linked your function here
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
        SizedBox(height: 0),
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
          const Divider(),
          _buildMenuItem(Icons.logout, 'Logout', () {}, textColor: Colors.red, iconColor: Colors.red),
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