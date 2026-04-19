import 'package:gestabsence/services/api_service.dart';

class MatiereService {
  static Future<List<Map<String, dynamic>>> getAllMatieres() async {
    final response = await ApiService.get('/admin/matieres.php');
    if (response['success'] == 1 && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data'] as List);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getMatiere(int id) async {
    final response = await ApiService.get('/admin/matieres.php?id=$id');
    if (response['success'] == 1 && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>> createMatiere({
    required String nom,
  }) async {
    return ApiService.post('/admin/matieres.php', {
      'nom': nom,
    });
  }

  static Future<Map<String, dynamic>> deleteMatiere(int id) async {
    return ApiService.delete('/admin/matieres.php?id=$id');
  }
}