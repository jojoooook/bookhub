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
import 'package:bookhub/services/auth_service.dart';

import 'package:provider/provider.dart';
import 'package:bookhub/services/profile_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadDarkModePreference();

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const BookHub(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final ProfileService _profileService = ProfileService();

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> loadDarkModePreference() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        _isDarkMode = profile.darkMode;
        notifyListeners();
      }
    } catch (e) {
      // Handle error if needed
      print('Error loading dark mode preference: $e');
    }
  }
}

class BookHub extends StatelessWidget {
  const BookHub({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'BookHub',
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF233973),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFEF760C),
          onPrimary: Colors.black,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: LoginScreen.routeName,
      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return DetailScreen(book: book);
        },
        ProfileScreen.routeName: (context) => ProfileScreen(
              onThemeChanged: (bool isDarkMode) {
                themeProvider.setDarkMode(isDarkMode);
              },
            ),
        SearchScreen.routeName: (context) => const SearchScreen(),
        RatingScreen.routeName: (context) => RatingScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        FavoriteScreen.routeName: (context) => const FavoriteScreen(),
      },
    );
  }
}
