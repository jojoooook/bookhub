import 'package:flutter/material.dart';
import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart';
import 'package:bookhub/screens/search_screen.dart';
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:bookhub/screens/login_screen.dart';
import 'package:bookhub/screens/rating_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub',
      initialRoute: MainScreen.routeName,
      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) => DetailScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        // EditProfileScreen.routeName: (context) => const EditProfileScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        RatingScreen.routeName: (context) =>  RatingScreen(),
      },
    );
  }
}
