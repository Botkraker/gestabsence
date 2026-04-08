import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/services/api_service.dart';

class SessionService {
  static Future<List<Seance>> getAllSessions() async {
    final response = await ApiService.get('/admin/seances.php');
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Seance(id: data['id'], classe: data['classe_nom'], matiere: data['matiere_nom'], date: data['date_seance'], heureDebut: data['heure_debut'], heureFin: data['heure_fin']))
          .toList();
    }
    return [];
  }

  static Future<Seance?> getSession(int id) async {
    final response = await ApiService.get('/admin/seances.php?id=$id');
    if (response['success'] == true && response['data'] is Map) {
      var data= response['data'] as Map<String, dynamic>;

      return Seance(id: data['id'], classe: data['classe_nom'], matiere: data['matiere_nom'], date: data['date_seance'], heureDebut: data['heure_debut'], heureFin: data['heure_fin']);
    }
    return null;
  }

  static Future<Map<String, dynamic>> createSession({
    required int enseignantId,
    required int classeId,
    required int matiereId,
    required String dateSeance,
    required String heureDebut,
    required String heureFin,
  }) async {
    return ApiService.post('/admin/seances.php', {
      'enseignant_id': enseignantId,
      'classe_id': classeId,
      'matiere_id': matiereId,
      'date_seance': dateSeance,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
    });
  }

  static Future<List<Seance>> getTeacherSessions(int teacherId) async {
    final response = await ApiService.get('/enseignant/seances.php?enseignant_id=$teacherId');
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Seance(id: data['id'], classe: data['classe_nom'], matiere: data['matiere_nom'], date: data['date_seance'], heureDebut: data['heure_debut'], heureFin: data['heure_fin']))
          .toList();
    }
    return [];
  }

  static Future<Seance?> getTeacherSession(int teacherId, int sessionId) async {
    final response = await ApiService.get(
      '/enseignant/seances.php?enseignant_id=$teacherId&id=$sessionId',
    );
    if (response['success'] == true && response['data'] is Map) {
      var data= response['data'] as Map<String, dynamic>;
      return Seance(id: data['id'], classe: data['classe_nom'], matiere: data['matiere_nom'], date: data['date_seance'], heureDebut: data['heure_debut'], heureFin: data['heure_fin']);
    }
    return null;
  }
}
