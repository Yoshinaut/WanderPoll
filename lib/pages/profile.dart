import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222429),
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
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/profileicon.jpg'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor:Color(0xFFad2a2a),
              radius: 14,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: () {},
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
      leading: Icon(icon, color: iconColor ??Color(0xFFad2a2a)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}