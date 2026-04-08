import 'package:gestabsence/services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return ApiService.post('/auth/login.php', {
      'email': email,
      'password': password,
    });
  }
}
