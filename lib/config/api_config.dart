import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with the current IPv4 address
const String baseUrl = 'http://10.0.2.2:8067';

/*
=============================================================================
                         API ENDPOINTS DOCUMENTATION
=============================================================================

AUTHENTICATION:
  POST /auth/login.php
    - Body: { email, password }
    - Returns: { success, user: { id, name, lastname, role } }

ADMIN ENDPOINTS:
  GET  /admin/etudiants.php           - Get all students
  GET  /admin/etudiants.php?id=<id>   - Get specific student
  POST /admin/etudiants.php           - Create new student
       Body: { nom, prenom, email, password, classe_id }
  
  GET  /admin/enseignants.php         - Get all teachers
  GET  /admin/enseignants.php?id=<id> - Get specific teacher
  POST /admin/enseignants.php         - Create new teacher
       Body: { nom, prenom, email, password, specialite }
  
  GET  /admin/seances.php             - Get all sessions
  GET  /admin/seances.php?id=<id>     - Get specific session
  POST /admin/seances.php             - Create new session
       Body: { enseignant_id, classe_id, matiere_id, date_seance, heure_debut, heure_fin }
  
  GET  /admin/classes.php             - Get all classes
  GET  /admin/classes.php?id=<id>     - Get specific class
  POST /admin/classes.php             - Create new class
       Body: { nom, niveau }

STUDENT ENDPOINTS:
  GET /etudiant/absences.php?id=<student_id>  - Get student absences
       Returns: { success, abscounter, data: [{nom, statut, ...}] }
  
  GET /etudiant/profil.php?id=<student_id>    - Get student profile
       Returns: { success, data: [{nom, prenom, email, classe, niveau}] }

TEACHER ENDPOINTS:
  GET  /enseignant/seances.php?enseignant_id=<id>     - Get teacher's sessions
  GET  /enseignant/seances.php?enseignant_id=<id>&id=<seance_id> - Get specific session
  
  POST /enseignant/absences.php                       - Record absences
       Body: { enseignant_id, seance_id, listabsence: [[etudiant_id, statut], ...] }

=============================================================================
*/

class ApiService {
  static const String _jsonHeader = 'application/json';
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': _jsonHeader, 'Accept': _jsonHeader},
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'GET Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': _jsonHeader, 'Accept': _jsonHeader},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'POST Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': _jsonHeader, 'Accept': _jsonHeader},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'PUT Error: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode >= 200 && response.statusCode < 300,
        ...decodedBody,
      };
    } catch (e) {
      return {
        'statusCode': response.statusCode,
        'success': false,
        'message': 'Failed to parse response: $e',
        'body': response.body,
      };
    }
  }

 
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return post('/auth/login.php', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> getAllStudents() async {
    return get('/admin/etudiants.php');
  }

  static Future<Map<String, dynamic>> getStudent(int id) async {
    return get('/admin/etudiants.php?id=$id');
  }


  static Future<Map<String, dynamic>> createStudent({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required int classeId,
  }) async {
    return post('/admin/etudiants.php', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'classe_id': classeId,
    });
  }

  static Future<Map<String, dynamic>> getAllTeachers() async {
    return get('/admin/enseignants.php');
  }

  static Future<Map<String, dynamic>> getTeacher(int id) async {
    return get('/admin/enseignants.php?id=$id');
  }

  static Future<Map<String, dynamic>> createTeacher({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? specialite,
  }) async {
    return post('/admin/enseignants.php', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      if (specialite != null) 'specialite': specialite,
    });
  }


  static Future<Map<String, dynamic>> getAllSessions() async {
    return get('/admin/seances.php');
  }

  static Future<Map<String, dynamic>> getSession(int id) async {
    return get('/admin/seances.php?id=$id');
  }


  static Future<Map<String, dynamic>> createSession({
    required int enseignantId,
    required int classeId,
    required int matiereId,
    required String dateSeance,
    required String heureDebut,
    required String heureFin,
  }) async {
    return post('/admin/seances.php', {
      'enseignant_id': enseignantId,
      'classe_id': classeId,
      'matiere_id': matiereId,
      'date_seance': dateSeance,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
    });
  }


  static Future<Map<String, dynamic>> getAllClasses() async {
    return get('/admin/classes.php');
  }

  static Future<Map<String, dynamic>> getClass(int id) async {
    return get('/admin/classes.php?id=$id');
  }

  static Future<Map<String, dynamic>> createClass({
    required String nom,
    String? niveau,
  }) async {
    return post('/admin/classes.php', {
      'nom': nom,
      if (niveau != null) 'niveau': niveau,
    });
  }


  static Future<Map<String, dynamic>> getStudentAbsences(int studentId) async {
    return get('/etudiant/absences.php?id=$studentId');
  }


  static Future<Map<String, dynamic>> getStudentProfile(int studentId) async {
    return get('/etudiant/profil.php?id=$studentId');
  }


  static Future<Map<String, dynamic>> getTeacherSessions(int teacherId) async {
    return get('/enseignant/seances.php?enseignant_id=$teacherId');
  }

  static Future<Map<String, dynamic>> getTeacherSession(
    int teacherId,
    int sessionId,
  ) async {
    return get(
      '/enseignant/seances.php?enseignant_id=$teacherId&id=$sessionId',
    );
  }


  static Future<Map<String, dynamic>> recordAbsences({
    required int enseignantId,
    required int seanceId,
    required List<List<dynamic>> listAbsence,
  }) async {
    return post('/enseignant/absences.php', {
      'enseignant_id': enseignantId,
      'seance_id': seanceId,
      'listabsence': listAbsence,
    });
  }
}
