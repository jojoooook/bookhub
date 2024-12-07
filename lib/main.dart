import 'package:flutter/material.dart';
import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart';  // Import MainScreen
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookhub/screens/search_screen.dart';

void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub',
      // Set MainScreen sebagai layar awal
      initialRoute: LoginScreen.routeName,
      routes: {
        // Define routes untuk masing-masing screen
        MainScreen.routeName: (context) => const MainScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) => DetailScreen(), // Ganti dengan parameter yang sesuai
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        // EditProfileScreen.routeName: (context) => const EditProfileScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
      },
    );
  }
}
