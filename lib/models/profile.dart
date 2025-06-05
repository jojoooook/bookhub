class Profile {
  String name;
  String email;
  String phone;
  String birthday;
  bool darkMode;

  Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthday,
    this.darkMode = false,
  });
}
