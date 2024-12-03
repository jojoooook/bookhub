import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart';
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub', // Set the title of your app
      initialRoute: ProfileScreen.routeName, // Set initial route to ProfileScreen
      routes: {
        '/home': (context) => HomeScreen(), // Define the route for HomeScreen
        ProfileScreen.routeName: (context) => ProfileScreen(), // Define ProfileScreen route here
      },
    );
  }
}
