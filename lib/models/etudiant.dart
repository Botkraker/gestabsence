import 'package:gestabsence/models/utilisateur.dart';

class Etudiant {
  final int id;
  final Utilisateur utilisateur;
  final String classe;
  Etudiant({
    required this.id,
    required this.utilisateur,
    required this.classe,
  });
}