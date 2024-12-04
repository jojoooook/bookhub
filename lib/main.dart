import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart';
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/screens/search_screen.dart';

import 'data/book_data.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(home: MainScreen());
//     // Set HomeScreen sebagai layar awal
//     // initialRoute: HomeScreen.routeName, // Set initial route to ProfileScreen
//     // routes: {
//     //   '/home': (context) => HomeScreen(), // Define the route for HomeScreen
//     //   ProfileScreen.routeName: (context) => ProfileScreen(), // Define ProfileScreen route here
//   }
// }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub',
      initialRoute: HomeScreen.routeName, // Set the HomeScreen as the initial route
      routes: {
        // Define routes for each screen
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) => DetailScreen(bookIndex: 0), // Ganti dengan index buku yang sesuai
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        // EditProfileScreen.routeName: (context) => const EditProfileScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
      },
    );
  }
}
