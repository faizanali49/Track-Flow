// lib/screens/employee_login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/provider/theme_check.dart';
import 'package:trackerdesktop/views/login_authentication/services/web_auth.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  _EmployeeLoginScreenState createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _mounted = true;

  // In _EmployeeLoginScreenState class in login_view.txt
  Future<void> _login() async {
    print('Login button pressed');
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Attempting login with email: ${_emailController.text.trim()}');

      final authService = WindowsAuthService();
      // bool success = await authService.signInWithEmail(email, password);

      // Try to sign in
      final success = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && context.mounted) {
        // Update username provider with email
        ref.read(userNameProvider.notifier).state = _emailController.text
            .trim();
        // Navigate to dashboard
        context.go('/dashboard');
      } else {
        // This case might be less likely now, but handle if signIn returns false
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login process completed but access was not granted.',
              ),
              backgroundColor:
                  Colors.orange, // Different color for logic issues
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors, including our custom ones
      print('FirebaseAuthException during login: ${e.code} - ${e.message}');
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      } else if (e.code == 'not-employee' || e.code == 'invalid-user-data') {
        errorMessage =
            e.message ??
            'Access denied. You are not authorized as an employee.';
      } else if (e.code == 'company-access-denied') {
        errorMessage = e.message ?? 'Please use the company portal.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled.';
      }
      // Add more conditions for other FirebaseAuthException codes as needed

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red, // Error color
          ),
        );
      }
    } catch (e) {
      // Handle any other unexpected errors
      print('Unexpected error during login: $e');
      if (context.mounted) {
        String errorMessage = 'An unexpected error occurred. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Ensure loading is stopped
      if (mounted) {
        // Check if the widget is still mounted
        setState(() => _isLoading = false);
      }
    }
  }

  // Don't forget to dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(desktopCurrentTheme);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: Container(
        // height: 500,
        // width: 400, // Set a fixed width for better appearance
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          // borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              // Image.asset(
              //   isDarkMode
              //       ? 'assets/images/scrapy-white.png'
              //       : 'assets/images/scrape.png',
              //   height: 60,
              // ),
              const SizedBox(height: 30),

              // Title
              Text(
                'Employee Portal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextFormField(
                controller: _emailController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
