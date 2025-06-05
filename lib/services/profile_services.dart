import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookhub/models/profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveProfile(Profile profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final data = {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'birthday': profile.birthday,
      'darkMode': profile.darkMode, // Pastikan darkMode juga disimpan
    };

    await userDoc.set(data, SetOptions(merge: true));
  }

  Future<Profile?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    return Profile(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      birthday: data['birthday'] ?? '',
      darkMode: data['darkMode'] ?? false, // Pastikan darkMode juga diambil
    );
  }
}
