import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/services/api_service.dart';

class TeacherService {
  static Future<List<Utilisateur>> getAllTeachers() async {
    final response = await ApiService.get('/admin/enseignants.php');
    if (response['success'] == 1 && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Utilisateur.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<Utilisateur?> getTeacher(int id) async {
    final response = await ApiService.get('/admin/enseignants.php?id=$id');
    if (response['success'] == 1 && response['data'] is Map) {
      return Utilisateur.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  static Future<Map<String, dynamic>> createTeacher({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? specialite,
  }) async {
    return ApiService.post('/admin/enseignants.php', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'specialite': ?specialite,
    });
  }
}
