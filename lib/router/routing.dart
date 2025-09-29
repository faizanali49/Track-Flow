// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackerdesktop/views/login_authentication/login_view.dart';
import 'package:trackerdesktop/views/widgets/home_screen.dart';
import 'package:trackerdesktop/views/login_authentication/services/login_auth.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Set up a listener for auth state
  final authStateListenable = ValueNotifier<bool>(false);

  // Check authentication on app start
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final webAuthService = WindowsAuthService();
    final isAuth = await webAuthService.isAuthenticated();
    authStateListenable.value = isAuth;
  });

  // Create the router instance
  return GoRouter(
    refreshListenable: authStateListenable,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) async {
      final webAuthService = WindowsAuthService();
      final isAuthenticated = await webAuthService.isAuthenticated();
      final isGoingToLogin = state.fullPath == '/login';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
});
