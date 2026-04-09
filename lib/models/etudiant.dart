import 'package:gestabsence/models/utilisateur.dart';

class Etudiant {
  final int id;
  final Utilisateur utilisateur;
  String? classe;
  String? niveau;
  Etudiant({
    required this.id,
    required this.utilisateur,
    this.classe,
    this.niveau,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: int.tryParse(json['etudiant_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      utilisateur: json['utilisateur'] is Map<String, dynamic>
          ? Utilisateur.fromJson(json['utilisateur'] as Map<String, dynamic>)
          : Utilisateur(
              id: int.tryParse(json['utilisateur_id']?.toString() ?? ''),
              nom: json['nom']?.toString(),
              prenom: json['prenom']?.toString(),
              email: json['email']?.toString(),
              role: json['role']?.toString(),
            ),
      classe: json['classe_nom']?.toString() ?? json['classe']?.toString(),
      niveau: json['niveau']?.toString(),
    );
  }
}