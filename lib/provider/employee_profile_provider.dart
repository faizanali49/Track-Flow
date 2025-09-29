import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:trackerdesktop/provider/employee_profile_model.dart';
import 'package:trackerdesktop/provider/states.dart';

final logger = Logger();

// final companyEmailProviderID = StateProvider<String?>((ref) => null);
// final employeeEmailProviderID = StateProvider<String?>((ref) => null);

final employeeProfileProvider =
    FutureProvider.autoDispose<Employee?>((ref) async {
  final companyEmail = ref.watch(companyEmailProvider);
  final employeeEmail = ref.watch(employeeEmailProvider);

  if (companyEmail == null || employeeEmail == null) {
    logger.e("❌ Error: Company email or Employee email is null.");
    return null;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyEmail)
        .collection('employees')
        .doc(employeeEmail)
        .get();

    if (!doc.exists) {
      logger.e("❌ Error: No employee found with email $employeeEmail");
      return null;
    }

    return Employee.fromFirestore(doc);
  } catch (e) {
    logger.e("❌ Error fetching employee profile: $e");
    return null;
  }
});