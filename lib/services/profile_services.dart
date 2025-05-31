import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:bookhub/models/profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save profile data to Firestore and upload profile image if provided
  Future<void> saveProfile(Profile profile, {html.File? profileImage}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    String? photoUrl;
    if (profileImage != null) {
      try {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(profileImage);
        await reader.onLoad.first;
        final bytes = reader.result as Uint8List;

        final ref =
            _storage.ref().child('profile_images').child('${user.uid}.jpg');
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        photoUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading profile image: $e');
        rethrow;
      }
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final data = {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'birthday': profile.birthday,
    };
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  // Get profile data from Firestore
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
    );
  }
}
