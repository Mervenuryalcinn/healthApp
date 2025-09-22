// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emülatör için localhost
  static const String baseUrl = 'http://10.0.2.2:5000';
  /// Genel POST isteği
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null && result is Map<String, dynamic>) {
          return result;
        } else {
          return {'success': false, 'error': 'Geçersiz yanıt formatı'};
        }
      } else {
        return {'success': false, 'error': 'Sunucu hatası: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'İstek gönderilemedi: $e'};
    }
  }
  /// Diyabet tahmini
  static Future<Map<String, dynamic>> predictDiabetes(Map<String, dynamic> data) async {
    // Backend’de gerekli alanlar kontrolü
    final requiredFields = [
      'gender', 'age', 'hypertension', 'heart_disease',
      'smoking_history', 'bmi', 'HbA1c_level', 'blood_glucose_level', 'diabetes'
    ];
    for (var field in requiredFields) {
      if (!data.containsKey(field)) {
        return {'success': false, 'error': '$field is required'};
      }
    }
    return await postRequest('predict_diabetes', data);
  }
  /// Genel sağlık analizi
  static Future<Map<String, dynamic>> analyzeHealthData(Map<String, dynamic> healthData) async {
    return await postRequest('analyze_health', healthData);
  }
  /// Test endpoint
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'Sunucu hatası: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Test bağlantısı hatası: $e'};
    }
  }
}
