import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      String uid, String name, String phone, DateTime birthday) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'phone': phone,
        'birthday': birthday.toIso8601String(),
      });
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
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
