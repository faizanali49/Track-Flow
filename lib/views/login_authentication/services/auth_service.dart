// // lib/services/employee_auth_service.dart
// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class EmployeeAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Login for employees
//   Future<User?> signInEmployee({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       print('Starting Firebase login attempt...');

//       // Firebase Auth login
//       final credential = await _auth
//           .signInWithEmailAndPassword(email: email, password: password)
//           .timeout(
//             const Duration(seconds: 15),
//             onTimeout: () => throw TimeoutException('Authentication timed out'),
//           );

//       print('Firebase auth response received');

//       final user = credential.user;
//       if (user == null) return null;

//       // Check if this user is an employee
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();

//       if (!userDoc.exists) {
//         // ❌ No user document found
//         await _auth.signOut();
//         throw FirebaseAuthException(
//           code: 'not-employee',
//           message: 'This account is not registered as an employee.',
//         );
//       }

//       final role = userDoc.get('role');
//       if (role != 'employee') {
//         // ❌ Not an employee user - check if it's a company
//         if (role == 'company') {
//           await _auth.signOut();
//           throw FirebaseAuthException(
//             code: 'company-access-denied',
//             message:
//                 'Access denied. This account is registered as a company. Please use the company portal.',
//           );
//         }

//         // ❌ Unknown role
//         await _auth.signOut();
//         throw FirebaseAuthException(
//           code: 'not-employee',
//           message: 'This account is not registered as an employee.',
//         );
//       }

//       // Check if email is verified
//       if (!user.emailVerified) {
//         // Send verification email
//         await user.sendEmailVerification();

//         // Sign out and throw exception
//         await _auth.signOut();
//         throw FirebaseAuthException(
//           code: 'email-not-verified',
//           message:
//               'Your email is not verified. A verification email has been sent to your email address.',
//         );
//       }

//       return user; // ✅ Employee user found and verified
//     } on FirebaseAuthException catch (e) {
//       print('Firebase Auth Exception Details:');
//       print('- Code: ${e.code}');
//       print('- Message: ${e.message}');
//       print('- Stack: ${e.stackTrace}');

//       // Rethrow with more info
//       throw Exception('${e.code}: ${e.message}');
//     } catch (e, stack) {
//       print('General error with stack trace:');
//       print(e);
//       print(stack);
//       throw Exception(e.toString());
//     }
//   }

//   // Check if user is logged in
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }

// // Provider for employee authentication service
// final employeeAuthServiceProvider = Provider<EmployeeAuthService>((ref) {
//   return EmployeeAuthService();
// });
