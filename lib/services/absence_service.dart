import 'package:gestabsence/models/absence.dart';
import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/services/api_service.dart';

class AbsenceService {
  static Future<bool> recordAbsences({
    required int seanceId,
    required List<List<dynamic>> listAbsence,
  }) async {
    final response = await ApiService.post('/enseignant/absences.php', {
      'seanceid': seanceId,
      'listabsence': listAbsence,
    });

    return response['success'] == 1;
  }
    static Future<List<Absence>> getStudentAbsences(int studentId) async {
    final response = await ApiService.get('/etudiant/absences.php?id=$studentId');
    if (response['success'] == 1 && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Absence(
            seance: Seance(
              date: DateTime.tryParse(data['date_seance']),
              heureDebut: data['heure_debut']?.toString(),
              heureFin: data['heure_fin']?.toString(),
            ),
            studentName: Etudiant(
              id: studentId,
              utilisateur: Utilisateur(nom: data["nom"]),
            ),
            status: data['statut'],
          ))
          .toList();
    }
    return [];
  }
}
