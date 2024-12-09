// import 'package:bookhub/screens/main_screen.dart';
// import 'package:bookhub/screens/search_screen.dart';
import 'package:bookhub/screens/login_screen.dart';
import 'package:bookhub/screens/register_screen.dart';
// import 'package:bookhub/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BookHub());
}

class BookHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: RegisterScreen.routeName, // Rute awal
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        // MainScreen.routeName: (context) => const MainScreen(),
        // Tambahkan rute lainnya jika diperlukan
      },
    );
  }
}
