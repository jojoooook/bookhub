import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _uidKey = 'uid';
  static const String _emailKey = 'email';

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print('Sign Up FirebaseAuthException: $e');
      rethrow;
    } catch (e) {
      print('Sign Up Error: $e');
      rethrow;
    }
  }

  // Save additional user profile data to Firestore
  Future<void> saveUserProfile(
      String uid,
      String name,
      String phone,
      DateTime birthday,
      String email, // <-- Tambahkan parameter email
      bool darkMode // <-- Tambahkan parameter darkMode
      ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'phone': phone,
        'birthday':
            birthday.toIso8601String().split('T')[0], // Simpan hanya tanggal
        'email': email, // <-- Simpan email
        'darkMode': darkMode, // <-- Simpan darkMode
      });
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      if (user != null) {
        // Persist user credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_uidKey, user.uid);
        await prefs.setString(_emailKey, email);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      print(e.code); // For debugging
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      }
      throw Exception('Failed to sign in: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Check if user is already signed in
  Future<String?> checkSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_uidKey);

    if (uid != null) {
      return uid;
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No user found for that email address.');
      }
      throw Exception('Failed to send password reset email: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Remove stored credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
    await prefs.remove(_emailKey);
  }

  // Get current user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Fetch user profile data from Firestore by uid
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
