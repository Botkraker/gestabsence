import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/services/api_service.dart';

class TeacherService {
  static Future<List<Utilisateur>> getAllTeachers() async {
    final response = await ApiService.get('/admin/enseignants.php');
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((json) => Utilisateur.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<Utilisateur?> getTeacher(int id) async {
    final response = await ApiService.get('/admin/enseignants.php?id=$id');
    if (response['success'] == true && response['data'] is Map) {
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
      if (specialite != null) 'specialite': specialite,
    });
  }
}
