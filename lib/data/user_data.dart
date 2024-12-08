import 'package:bookhub/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Daftar pengguna
var userList = [
  User(name: 'Jonathan', email: 'jonathan@gmail.com', password: '123456'),
  User(name: 'Marco', email: 'marco@gmail.com', password: '654321'),
];

/// Pengguna yang sedang login
User? currentUser;

/// Fungsi login
Future<bool> loginUser(String email, String password) async {
  for (User user in userList) {
    if (user.email == email && user.password == password) {
      currentUser = user;

      // Simpan data pengguna yang login ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentEmail', currentUser!.email);

      return true;
    }
  }
  return false;
}

/// Fungsi untuk memuat pengguna yang login dari SharedPreferences
Future<void> loadCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('currentEmail');

  if (email != null) {
    try {
      currentUser = userList.firstWhere(
            (user) => user.email == email,
      );
    } catch (e) {
      currentUser = null; // Jika pengguna tidak ditemukan
    }
  } else {
    currentUser = null; // Jika tidak ada data login tersimpan
  }
}

/// Fungsi logout
Future<void> logoutUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('currentEmail');
  currentUser = null;
}
