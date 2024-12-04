import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart';
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/search_screen.dart'; 
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen());
      // initialRoute: HomeScreen.routeName, // Set initial route to ProfileScreen
      // routes: {
      //   '/home': (context) => HomeScreen(), // Define the route for HomeScreen
      //   ProfileScreen.routeName: (context) => ProfileScreen(), // Define ProfileScreen route here
  }
