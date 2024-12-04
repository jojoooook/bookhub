import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/screens/home_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetailScreen(), // Panggil MainScreen dari screens/main_screen.dart
    );
  }
}
