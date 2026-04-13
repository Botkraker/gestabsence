import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/student_form_screen.dart';

class EditStudentScreen extends StatelessWidget {
  const EditStudentScreen({
    super.key,
    required this.student,
    required this.classes,
  });

  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> classes;

  @override
  Widget build(BuildContext context) {
    return StudentFormScreen(
      classes: classes,
      student: student,
      showAddFromEditButton: true,
    );
  }
}
