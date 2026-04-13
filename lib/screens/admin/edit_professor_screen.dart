import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/professor_form_screen.dart';

class EditProfessorScreen extends StatelessWidget {
  const EditProfessorScreen({
    super.key,
    required this.professor,
  });

  final Map<String, dynamic> professor;

  @override
  Widget build(BuildContext context) {
    return ProfessorFormScreen(professor: professor);
  }
}
