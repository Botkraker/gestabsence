import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/services/api_service.dart';

class StudentService {
  static Future<List<Etudiant>> getAllStudents() async {
    final response = await ApiService.get('/admin/etudiants.php');
    if (response['success'] == 1 && response['data'] is List) {
      return (response['data'] as List)
          .map((data) => Etudiant(
                id: int.parse(data['etudiant_id'].toString()),
                utilisateur: Utilisateur(
                  id: int.parse(data['utilisateur_id'].toString()),
                  nom: data['nom'],
                  prenom: data['prenom'],
                  email: data['email'],
                  role: data['role'],
                ),
                classe: data['classe_nom'],
              ))
          .toList();
    }
    return [];
  }

  static Future<Etudiant?> getStudent(int id) async {
    final response = await ApiService.get('/admin/etudiants.php?id=$id');
    if (response['success'] == 1 && response['data'] is Map) {
      var data= response['data'] as Map<String, dynamic>;
      return Etudiant(
                id: data['etudiant_id'],
                utilisateur: Utilisateur(
                  id: data['utilisateur_id'],
                  nom: data['nom'],
                  prenom: data['prenom'],
                  email: data['email'],
                  role: data['role'],
                ),
                classe: data['classe_nom'],
              );
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



  static Future<Map<String, dynamic>> getStudentProfile(int studentId) async {
    return ApiService.get('/etudiant/profil.php?id=$studentId');
  }
}
