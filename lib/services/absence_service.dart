import 'package:gestabsence/models/absence.dart';
import 'package:gestabsence/services/api_service.dart';

class AbsenceService {
  static Future<bool> recordAbsences({
    required int seanceId,
    required List<Map<String, dynamic>> listAbsence,
  }) async {
    final response = await ApiService.post('/enseignant/absences.php', {
      'seance_id': seanceId,
      'listabsence': listAbsence,
    });

    return response['success'] == 1;
  }
    static Future<List<Absence>> getStudentAbsences(int studentId) async {
    final response = await ApiService.get('/etudiant/absences.php?id=$studentId');
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Absence( seance: data['seance'], studentName: data['studentName'], status: data['status']))
          .toList();
    }
    return [];
  }
}
