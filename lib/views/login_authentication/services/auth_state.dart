// // lib/provider/employee_auth_state.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:trackerdesktop/views/login_authentication/services/auth_service.dart'; // Fixed import path

// final employeeAuthStateProvider =
//     StateNotifierProvider<EmployeeAuthStateNotifier, AsyncValue<User?>>((ref) {
//       final authService = ref.read(
//         employeeAuthServiceProvider,
//       ); // Fixed provider name
//       return EmployeeAuthStateNotifier(authService);
//     });

// class EmployeeAuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
//   final EmployeeAuthService _authService;

//   EmployeeAuthStateNotifier(this._authService) : super(const AsyncData(null));

//   Future<void> login(String email, String password) async {
//     state = const AsyncLoading();
//     try {
//       final user = await _authService.signInEmployee(
//         email: email,
//         password: password,
//       );
//       state = AsyncData(user);
//     } catch (e) {
//       state = AsyncError(e, StackTrace.current);
//     }
//   }

//   Future<void> logout() async {
//     await _authService.signOut();
//     state = const AsyncData(null);
//   }

//   User? get currentUser => _authService.getCurrentUser();
// }

// // Add this to your auth_state.dart file for debugging

// class EmployeeAuthState extends StateNotifier<AsyncValue<User?>> {
//   EmployeeAuthState() : super(const AsyncValue.loading()) {
//     // Initialize state
//     _checkCurrentUser();
//   }

//   Future<void> _checkCurrentUser() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       state = AsyncValue.data(user);
//     } catch (e) {
//       print('Error checking current user: $e');
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   Future<void> login(String email, String password) async {
//     try {
//       state = const AsyncValue.loading();
//       print('AuthState: Attempting login');

//       // Try direct Firebase auth
//       final userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);

//       print(
//         'AuthState: Firebase auth successful, user: ${userCredential.user?.email}',
//       );

//       // Additional verification if needed
//       final user = userCredential.user;
//       if (user == null) {
//         throw Exception('User is null after authentication');
//       }

//       // Update state with user
//       state = AsyncValue.data(user);
//       print('AuthState: State updated with user');
//     } catch (e) {
//       print('Firebase Auth Error: ${e.runtimeType} - ${e.toString()}');
//       state = AsyncValue.error(e, StackTrace.current);
//       throw Exception(e.toString());
//     }
//   }

//   // Other methods...
// }
