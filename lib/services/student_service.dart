import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/services/api_service.dart';

class StudentService {
  static Future<List<Etudiant>> getAllStudents() async {
    final response = await ApiService.get('/admin/etudiants.php');
    if (response['success'] == 1 && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Etudiant.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<Etudiant?> getStudent(int id) async {
    final response = await ApiService.get('/admin/etudiants.php?id=$id');
    if (response['success'] == 1 && response['data'] is Map) {
      return Etudiant.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  static Future<Map<String, dynamic>> createStudent({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required int classeId,
  }) async {
    return ApiService.post('/admin/etudiants.php', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'classe_id': classeId,
    });
  }



  static Future<Etudiant?> getStudentProfile(int studentId) async {
    final response = await ApiService.get('/etudiant/profil.php?id=$studentId');
    if (response['success'] == 1 && response['data'] is Map) {
      return Etudiant.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }
  static Future<Etudiant?> getStudentProfileByUserId(int userId) async {
    final response = await ApiService.get('/etudiant/profil.php?utilisateur_id=$userId');
    if (response['success'] == 1) {
      var data= response['data'] as List;
      return Etudiant.fromJson(data[0] as Map<String, dynamic>);
    }
    return null;
  }
}
