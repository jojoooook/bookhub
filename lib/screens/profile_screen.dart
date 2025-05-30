import 'package:flutter/material.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/models/profile.dart';
import 'package:bookhub/services/profile_services.dart';
import 'package:bookhub/data/user_data.dart'; // Untuk fungsi logout
import 'package:bookhub/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile profile = Profile(
    name: 'Default Name',
    email: 'default@example.com',
    phoneNumber: '000-0000-0000',
    birthday: '01-01-2000',
  );

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authService = AuthService();
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null) {
      final userData = await authService.fetchUserProfile(firebaseUser.uid);
      if (userData != null) {
        setState(() {
          profile = Profile(
            name: userData['name'] ?? 'No Name',
            email: firebaseUser.email ?? 'No Email',
            phoneNumber: userData['phone'] ?? 'No Phone',
            birthday: userData['birthday'] ?? 'No Birthday',
          );
        });
      }
    }
  }

  Future<void> _logout() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      await logoutUser(); // Fungsi logout dari user_data.dart
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      ); // Navigasi ke LoginScreen
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profil
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/profile_screen.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                const Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 170,
                  left: MediaQuery.of(context).size.width / 2 - 80,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.asset(
                        'images/avatar.png',
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 130),
            // Informasi Profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProfileInfoRow(
                    icon: Icons.person,
                    label: 'Name',
                    value: profile.name,
                  ),
                  ProfileInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: profile.email,
                  ),
                  ProfileInfoRow(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: profile.phoneNumber,
                  ),
                  ProfileInfoRow(
                    icon: Icons.cake,
                    label: 'Birthday Date',
                    value: profile.birthday,
                  ),
                  const SizedBox(height: 20),
                  // Tombol Edit Profil
                  _buildButton(
                    text: 'Edit Profile',
                    backgroundColor: const Color(0xFF233973),
                    textColor: Colors.white,
                    onPressed: () async {
                      final updatedProfile = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      );
                      if (updatedProfile != null) {
                        setState(() {
                          profile = updatedProfile;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Tombol Logout
                  _buildButton(
                    text: 'Logout',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50), // Lebar penuh
        padding: const EdgeInsets.symmetric(vertical: 13), // Padding konsisten
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Sudut membulat
        ),
        backgroundColor: backgroundColor, // Warna tombol
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor, // Warna teks
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
