import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<bool> logoutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true; // Indicate successful logout
  } on FirebaseAuthException catch (e) {
    print("Error during logout: ${e.message}");
    return false; // Indicate logout failure
  }
  // Navigate to LoginScreen after successful logout
  // Navigator.pushReplacementNamed(context, '/login');
}
