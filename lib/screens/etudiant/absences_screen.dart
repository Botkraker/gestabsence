import 'package:flutter/material.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key,required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("absences");
  }
}