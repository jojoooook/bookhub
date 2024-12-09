import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Perlu untuk GestureRecognizer

class RegisterScreen extends StatelessWidget {
  static const String routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFF233973),
                        image: DecorationImage(
                          image: AssetImage('images/profile_screen.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField('Email Address', Icons.email_outlined),
                          const SizedBox(height: 16),
                          _buildTextField('Name', Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildTextField('Phone Number', Icons.phone_outlined),
                          const SizedBox(height: 16),
                          _buildTextField('Birthday Date', Icons.cake_outlined),
                          const SizedBox(height: 16),
                          _buildTextField('Password', Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xFF233973),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: const TextStyle(color: Color(0xFF233973)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
