  import 'package:bookhub/screens/home_screen.dart'; 
  import 'package:bookhub/screens/search_screen.dart'; 
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
        home: HomeScreen(),
        routes: {
          SearchScreen.routeName: (context) => SearchScreen(), 
      }, 
      );  
    }
  }
