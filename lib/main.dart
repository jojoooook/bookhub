import 'package:bookhub/screens/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/screens/home_screen.dart';
import 'package:bookhub/screens/main_screen.dart'; // Pastikan ini mengacu pada MainScreen Anda
import 'package:bookhub/screens/search_screen.dart';
import 'package:bookhub/screens/profile_screen.dart';
import 'package:bookhub/screens/login_screen.dart';
import 'package:bookhub/screens/rating_screen.dart';
import 'package:bookhub/screens/register_screen.dart';
import '/models/book.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

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
    print('ThemeProvider: setDarkMode dipanggil dengan value: $value');
    if (_isDarkMode != value) { // Hanya update jika berbeda
      _isDarkMode = value;
      notifyListeners();
      print('ThemeProvider: notifyListeners dipanggil');
    }
  }

  Future<void> loadDarkModePreference() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        _isDarkMode = profile.darkMode;
        // Panggil notifyListeners hanya jika _isDarkMode berubah dari nilai awal
        // agar tidak memicu build yang tidak perlu saat startup
        if (_isDarkMode != profile.darkMode) {
          notifyListeners();
        }
      }
    } catch (e) {
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
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF233973),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEF760C),
          onPrimary: Colors.black,
          surface: Color(0xFF121212),
          onSurface: Colors.white,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // StreamBuilder langsung di properti 'home' untuk menentukan rute awal
      // berdasarkan status autentikasi. Ini tidak akan memicu navigasi ulang
      // saat tema berubah.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Menampilkan loading screen saat menunggu data autentikasi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Jika ada pengguna yang login, tampilkan MainScreen
          if (snapshot.hasData) {
            return const MainScreen(); // MainScreen Anda yang berisi BottomNavigationBar
          }
          // Jika tidak ada pengguna yang login, tampilkan LoginScreen
          return const LoginScreen();
        },
      ),

      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        DetailScreen.routeName: (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return DetailScreen(book: book);
        },
        // Pastikan ProfileScreen tidak memiliki parameter onThemeChanged
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        RatingScreen.routeName: (context) => const RatingScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        FavoriteScreen.routeName: (context) => const FavoriteScreen(),
      },
    );
  }
}