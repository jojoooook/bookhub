import 'package:flutter/material.dart';
import 'package:bookhub/models/profile.dart'; // Pastikan untuk mengimpor model Profile

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  EditProfileScreen({required this.profile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _birthdayController = TextEditingController(text: widget.profile.birthday);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  // Validasi data sebelum disimpan
  void _saveProfile() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
        _phoneController.text.isEmpty || _birthdayController.text.isEmpty) {
      // Tampilkan pesan kesalahan jika ada field yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled out')),
      );
      return;
    }

    // Update profil dengan data yang telah diubah
    Profile updatedProfile = Profile(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      birthday: _birthdayController.text,
    );

    // Simpan data profil ke penyimpanan atau lakukan navigasi
    Navigator.pop(context,
        updatedProfile); // Kembali ke ProfileScreen dengan data yang sudah diubah
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      resizeToAvoidBottomInset: true, // Pastikan ini true
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(labelText: 'Birthday'),
                ),
                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: const Color(0xFF233973),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Memberikan ruang ekstra di bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}