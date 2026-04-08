import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/seance.dart';

class Absence {                                                                                     
  final Seance seance;
  final Etudiant studentName;
  String status;
  Absence({
    required this.seance,
    required this.studentName,
    required this.status,                                                 
  });
}