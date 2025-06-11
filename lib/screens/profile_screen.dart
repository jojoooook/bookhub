import 'package:flutter/material.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/models/profile.dart';
import 'package:bookhub/services/profile_services.dart';
import 'package:bookhub/data/user_data.dart'; // Untuk fungsi logout
import 'package:bookhub/services/auth_service.dart';

// Import Provider and ThemeProvider
import 'package:provider/provider.dart';
import 'package:bookhub/main.dart'; // Asumsikan ThemeProvider ada di main.dart

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;

  const ProfileScreen({super.key, this.onThemeChanged});
  static const String routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile profile = Profile(
    name: 'Default Name',
    email: 'default@example.com',
    phone: '000-0000-0000',
    birthday: '01-01-2000',
    darkMode: false,
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
      // Pastikan widget masih ter-mount sebelum menggunakan context secara asynchronous
      if (!mounted) return;
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      final userData = await authService.fetchUserProfile(firebaseUser.uid);
      if (userData != null) {
        setState(() {
          profile = Profile(
            name: userData['name'] ?? 'No Name',
            email: firebaseUser.email ?? 'No Email',
            phone: userData['phone'] ?? 'No Phone',
            birthday: userData['birthday'] ?? 'No Birthday',
            // Selaraskan profile.darkMode dengan state ThemeProvider pada awalnya
            // Ini mengasumsikan ThemeProvider.isDarkMode menyimpan nilai persistensi yang benar.
            darkMode: themeProvider.isDarkMode,
          );
        });
      } else {
        // Jika userData null (misalnya, pengguna baru, fetch gagal),
        // tetap pastikan profile.darkMode selaras dengan ThemeProvider.
        // Ini memperbarui instance profile default.
        setState(() {
          profile = Profile(
            name: profile.name, // Pertahankan nilai default/yang sudah dimuat
            email: profile.email,
            phone: profile.phone,
            birthday: profile.birthday,
            darkMode: themeProvider.isDarkMode,
          );
        });
      }
    }
  }

  Future<void> _saveDarkModePreference(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setDarkMode(value);
    final profileService = ProfileService();
    profile.darkMode = value;
    await profileService.saveProfile(profile);
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(value);
    }
  }

  Future<void> _logout() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.setDarkMode(false);
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
              ],
            ),
            // Mengurangi jarak setelah header karena avatar dihilangkan
            const SizedBox(height: 30),
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
                    value: profile.phone,
                  ),
                  ProfileInfoRow(
                    icon: Icons.cake,
                    label: 'Birthday Date',
                    value: profile.birthday.contains('T')
                        ? profile.birthday.split('T')[0]
                        : profile.birthday,
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: Provider.of<ThemeProvider>(context).isDarkMode,
                    onChanged: (bool value) {
                      _saveDarkModePreference(value);
                    },
                    secondary: const Icon(Icons.dark_mode),
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
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
