import 'package:flutter/material.dart';
import 'home_screen.dart';

import 'favorite_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screenOptions = <Widget>[
    HomeScreen(),
    FavoriteScreen(),
    SearchScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF233973),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}