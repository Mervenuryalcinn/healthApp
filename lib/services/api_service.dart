// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emülatöründe backend’e bağlanmak için özel localhost adresi
  static const String baseUrl = 'http://10.0.2.2:5000';

  /// 🔹 Genel POST isteği
  /// - [endpoint]: Flask backend’de çağrılacak route (ör. "predict_diabetes")
  /// - [data]: JSON olarak gönderilecek body
  /// - Başarılı ise backend’den dönen JSON’u Map formatında döndürür.
  /// - Hata durumunda {'success': false, 'error': 'mesaj'} yapısı döndürür.
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Backend’in döndürdüğü yanıt Map değilse hata mesajı üret
        if (result != null && result is Map<String, dynamic>) {
          return result;
        } else {
          return {'success': false, 'error': 'Geçersiz yanıt formatı'};
        }
      } else {
        // Örneğin 500 veya 404 durumunda
        return {'success': false, 'error': 'Sunucu hatası: ${response.statusCode}'};
      }
    } catch (e) {
      // İnternet bağlantısı veya backend’e ulaşamama gibi durumlar
      return {'success': false, 'error': 'İstek gönderilemedi: $e'};
    }
  }

  /// 🔹 Diyabet tahmini isteği
  /// - Backend’e gerekli tüm alanlar iletilir ve doğrulama yapılır.
  /// - Eksik alan varsa direkt hata mesajı döndürür.
  static Future<Map<String, dynamic>> predictDiabetes(Map<String, dynamic> data) async {
    // Backend tarafında gerekli alanlar listesi
    final requiredFields = [
      'gender', 'age', 'hypertension', 'heart_disease',
      'smoking_history', 'bmi', 'HbA1c_level', 'blood_glucose_level', 'diabetes'
    ];

    // Eksik parametre kontrolü
    for (var field in requiredFields) {
      if (!data.containsKey(field)) {
        return {'success': false, 'error': '$field is required'};
      }
    }

    // POST isteği ile tahmin işlemi
    return await postRequest('predict_diabetes', data);
  }

  /// 🔹 Genel sağlık analizi isteği
  /// - Kullanıcının sağlık verilerini backend’e göndererek analiz sonucu döner.
  static Future<Map<String, dynamic>> analyzeHealthData(Map<String, dynamic> healthData) async {
    return await postRequest('analyze_health', healthData);
  }

  /// 🔹 Test bağlantısı
  /// - Backend’in çalışıp çalışmadığını test etmek için basit GET isteği
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
