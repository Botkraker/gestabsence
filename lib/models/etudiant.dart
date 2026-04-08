import 'package:gestabsence/models/utilisateur.dart';

class Etudiant {
  final int id;
  final Utilisateur utilisateur;
  String? classe;
  Etudiant({
    required this.id,
    required this.utilisateur,
    this.classe,
  });
}