import 'package:gestabsence/services/api_service.dart';

class ClassService {
  static Future<List<Map<String, dynamic>>> getAllClasses() async {
    final response = await ApiService.get('/admin/classes.php');
    if (response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data'] as List);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getClass(int id) async {
    final response = await ApiService.get('/admin/classes.php?id=$id');
    if (response['success'] == true && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>> createClass({
    required String nom,
    String? niveau,
  }) async {
    return ApiService.post('/admin/classes.php', {
      'nom': nom,
      if (niveau != null) 'niveau': niveau,
    });
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    return ApiService.get('/admin/stats.php');
  }
}
