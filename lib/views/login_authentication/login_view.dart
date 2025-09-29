// lib/screens/employee_login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/restore_app_state.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/views/login_authentication/services/login_auth.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  _EmployeeLoginScreenState createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _employeeEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyEmailController = TextEditingController(); // New controller
  bool _isLoading = false;

  @override
  void dispose() {
    _employeeEmailController.dispose();
    _passwordController.dispose();
    _companyEmailController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = WindowsAuthService();
      await authService.signInWithEmployeeCredentials(
        companyEmail: _companyEmailController.text.trim(),
        employeeEmail: _employeeEmailController.text.trim(),
        password: _passwordController.text.trim(),
        ref: ref, // <-- so restoreAppState runs
      );

      if (mounted) {
        ref.read(employeeEmailProvider.notifier).state =
            _employeeEmailController.text.trim();
        ref.read(companyEmailProvider.notifier).state = _companyEmailController
            .text
            .trim();
        await restoreAppState(
          ref,
          employeeEmailProvider.toString(),
          companyEmailProvider.toString(),
        );

        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Display a more user-friendly message for specific auth errors
        String errorMessage;
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password.';
        } else if (e.code == 'company-not-found') {
          errorMessage = 'Company not found. Please check the company email.';
        } else if (e.code == 'employee-not-found') {
          errorMessage =
              'Employee record not found under the specified company.';
        } else {
          errorMessage = 'An unexpected error occurred: ${e.message}';
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 400,
          // height: 450,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              // BoxShadow(
              //   offset: const Offset(0, 5),
              // ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Employee Login',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _companyEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Company Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _employeeEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
