import 'package:bookhub/screens/favorite_screen.dart';
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
import 'package:bookhub/screens/register_screen.dart';
import '/models/book.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:bookhub/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BookHub());
}

class BookHub extends StatelessWidget {
  const BookHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return DetailScreen(book: book);
        },
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        RatingScreen.routeName: (context) => RatingScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        FavoriteScreen.routeName: (context) => const FavoriteScreen(),
      },
    );
  }
}
