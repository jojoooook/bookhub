import 'package:flutter/material.dart';
import 'package:bookhub/screens/custom_bottom_navigation_bar.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/models/profile.dart';
import 'package:bookhub/services/profile_services.dart';


class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Menambahkan variabel untuk mengontrol index bottom navigation
  int _currentIndex = 3;

  late Profile profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Fungsi untuk memuat profil dari SharedPreferences
  Future<void> _loadProfile() async {
    Profile? loadedProfile = await ProfileService().getProfile();
    if (loadedProfile != null) {
      setState(() {
        profile = loadedProfile;
      });
    } else {
      setState(() {
        // Set data default jika tidak ada data yang disimpan
        profile = Profile(
          name: 'Default Name',
          email: 'default@example.com',
          phoneNumber: '000-0000-0000',
          birthday: '01-01-2000',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Membungkus seluruh konten dengan SingleChildScrollView
        child: Column(
          children: [
            // Profil Header
            Stack(
              clipBehavior: Clip.none, // Memungkinkan elemen keluar dari batas Stack
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
                  top: 170, // Posisi ini mengatur lingkaran keluar dari bagian bawah Container
                  left: MediaQuery.of(context).size.width / 2 - 80,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    child: ClipOval(
                      child: Image.asset(
                        'images/gatsby.jpeg',
                        fit: BoxFit.cover,
                        width: 160,
                        height: 160,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 130.0),

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
                  ElevatedButton(
                    onPressed: () async {
                      // Navigasi ke halaman EditProfileScreen dan tunggu hasilnya
                      final updatedProfile = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      );

                      // Jika data profil berubah, update tampilan
                      if (updatedProfile != null) {
                        setState(() {
                          profile = updatedProfile; // Update data profil
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color(0xFF233973),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Menambahkan Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              // Navigate to bookmark screen (replace with your actual logic)
            } else if (index == 2) {
              // Navigate to search screen (replace with your actual logic)
            } else if (index == 3) {
              Navigator.pushReplacementNamed(
                  context, '/profile'); // Navigate to Profile screen
            }
          });
        },
      ),
    );
  }
}

  class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

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
