import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/student_form_screen.dart';

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({
    super.key,
    required this.classes,
  });

  final List<Map<String, dynamic>> classes;

  @override
  Widget build(BuildContext context) {
    return StudentFormScreen(classes: classes);
  }
}
