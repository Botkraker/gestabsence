import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/models/utilisateur.dart';

class Absence {
  final Seance seance;
  final Etudiant studentName;
  String status;
  Absence({
    required this.seance,
    required this.studentName,
    required this.status,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      seance: json['seance'] is Map<String, dynamic>
          ? Seance.fromJson(json['seance'] as Map<String, dynamic>)
          : Seance(
              date: DateTime.tryParse(json['date_seance']?.toString() ?? ''),
              heureDebut: json['heure_debut']?.toString(),
              heureFin: json['heure_fin']?.toString(),
            ),
      studentName: json['studentName'] is Map<String, dynamic>
          ? Etudiant.fromJson(json['studentName'] as Map<String, dynamic>)
          : Etudiant(
              id: int.tryParse(json['etudiant_id']?.toString() ?? '') ?? 0,
              utilisateur: Utilisateur(nom: json['nom']),
            ),
      status: json['statut']?.toString() ?? json['status']?.toString() ?? '',
    );
  }
}
