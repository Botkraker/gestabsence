import 'package:gestabsence/models/absence.dart';
import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/services/api_service.dart';

class AbsenceService {
  static Future<Map<String, dynamic>> recordAbsences({
    required int seanceId,
    required List<List<dynamic>> listAbsence,
  }) async {
    return ApiService.post('/enseignant/absences.php', {
      'seanceid': seanceId,
      'listabsence': listAbsence,
    });
  }

  static Future<Map<int, String>> getSeanceAbsenceStatuses(int seanceId) async {
    final response = await ApiService.get('/enseignant/absences.php?seanceid=$seanceId');
    if (response['success'] == 1 && response['data'] is List) {
      final statuses = <int, String>{};
      for (final item in response['data'] as List) {
        if (item is Map<String, dynamic>) {
          final studentId = int.tryParse(item['etudiant_id']?.toString() ?? '');
          final status = item['statut']?.toString();
          if (studentId != null && status != null && status.isNotEmpty) {
            statuses[studentId] = status;
          }
        }
      }
      return statuses;
    }
    return <int, String>{};
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
