import 'package:bookhub/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookhub/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:bookhub/services/profile_services.dart';
import 'package:bookhub/main.dart'; // Ensure this points to the file defining ThemeProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _resetEmailController =
      TextEditingController(); // Controller for password reset email
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _resetEmailController.dispose(); // Don't forget to dispose this controller
    super.dispose();
  }

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and Password cannot be empty')),
      );
      return; // Exit early if fields are empty
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final profileService = ProfileService();
        final profile = await profileService.getProfile();
        if (profile != null) {
          themeProvider.setDarkMode(profile.darkMode);
        } else {
          themeProvider.setDarkMode(false);
        }
        if (mounted) { // Check if widget is still mounted before navigation
          Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
        }
      } else {
        // This might not be called since signIn will throw an exception
        // but it's good for fallback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
    } on Exception catch (e) {
      // Catch Exception from AuthService
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Login failed: ${e.toString().split(': ')[1]}')), // Display cleaner message
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Function to show password reset dialog ---
  void _showForgotPasswordDialog() {
    _resetEmailController.text = emailController.text
        .trim(); // Populate reset email with login email if available

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password?'),
          content: SingleChildScrollView(
            // To prevent keyboard from covering input
            child: ListBody(
              children: <Widget>[
                const Text(
                    'Enter your email to receive a password reset link.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Close dialog before sending email
                await _sendPasswordResetEmailFromDialog();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Function to send password reset email from dialog ---
  Future<void> _sendPasswordResetEmailFromDialog() async {
    String email = _resetEmailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email cannot be empty for password reset.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state for main screen (optional)
    });

    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'A password reset link has been sent to your email. Please check your inbox.'),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to send password reset link: ${e.toString().split(': ')[1]}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Main Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Image
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/profile_screen.png'), // Ensure correct image path
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Welcome Text
                    Text(
                      'Welcome to BookHub',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Login Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Please sign in to continue',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7)),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: emailController,
                            keyboardType:
                                TextInputType.emailAddress, // Added this
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              suffixIcon: TextButton(
                                // Replaced suffixText with TextButton in suffixIcon
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'FORGOT?',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('LOGIN',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
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
                  text: "Don't have an account? ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(
                              context, RegisterScreen.routeName);
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
}