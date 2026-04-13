import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestabsence/config/api_config.dart';

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
      return {'success': 0, 'message': 'GET Error: $e'};
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
      return {'success': 0, 'message': 'POST Error: $e'};
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
      return {'success': 0, 'message': 'PUT Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': _jsonHeader, 'Accept': _jsonHeader},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': 0, 'message': 'DELETE Error: $e'};
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
        'success': 0,
        'message': 'Failed to parse response: $e',
        'body': response.body,
      };
    }
  }
}
