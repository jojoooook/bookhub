import 'package:flutter/material.dart';
import 'custom_bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'login_screen.dart';
// import 'bookmark_screen.dart';
// import 'search_screen.dart';
// import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Melacak indeks tab yang sedang dipilih

  final List<Widget> _screens = [
    HomeScreen(),
    // BookmarkScreen(),
    // SearchScreen(),
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'), // Judul aplikasi
      ),
      body: _screens[
          _currentIndex], // Menampilkan layar sesuai dengan indeks saat ini
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah indeks saat ini
          });
        },
      ),
    );
  }
}
