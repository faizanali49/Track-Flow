import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;

  Employee({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employee(
      id: doc.id,
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
