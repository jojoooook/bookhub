import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookhub/models/profile.dart'; // Import Model Profile

class ProfileService {
  // Menyimpan data profil pengguna
  Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', profile.name);
    await prefs.setString('email', profile.email);
    await prefs.setString('phoneNumber', profile.phoneNumber);
    await prefs.setString('birthday', profile.birthday);
  }

  // Mengambil data profil pengguna
  Future<Profile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? phoneNumber = prefs.getString('phoneNumber');
    String? birthday = prefs.getString('birthday');

    if (name != null && email != null && phoneNumber != null && birthday != null) {
      return Profile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        birthday: birthday,
      );
    }

    return null; // Jika data tidak ada
  }
}
