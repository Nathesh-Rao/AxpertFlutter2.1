import 'dart:convert';
import 'package:http/http.dart' as http;

class OfflineDatasources {
  // HTTP CLIENT
  static final http.Client _client = http.Client();

  // API ENDPOINTS 
  static const String API_FETCH_OFFLINE_PAGES = '/api/offline/pages';
  static const String API_SUBMIT_OFFLINE_FORM = '/api/offline/submit';

  static String API_FETCH_DATASOURCE(String name) {
    return '/api/datasource/$name';
  }

  static String baseUrl = '';

  // COMMON HEADERS
  static Map<String, String> _jsonHeader({String? bearerToken}) {
    if (bearerToken != null && bearerToken.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  // GET CALL
  static Future<String?> get({
    required String endpoint,
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse(baseUrl + endpoint);
      final response = await _client.get(
        uri,
        headers: _jsonHeader(bearerToken: bearerToken),
      );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // POST CALL
  static Future<String?> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse(baseUrl + endpoint);
      final response = await _client.post(
        uri,
        headers: _jsonHeader(bearerToken: bearerToken),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
