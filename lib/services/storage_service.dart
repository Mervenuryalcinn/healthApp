// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

/// 🔹 StorageService
/// - Singleton sınıfı, kullanıcı verilerini hem Firestore hem de local storage (SharedPreferences) üzerinde yönetir.
/// - Kullanıcıya özel veriler için anahtar oluşturur.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static SharedPreferences? _prefs;
  String? _currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 SharedPreferences başlat
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 🔹 Kullanıcı ID'sini ayarla
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// 🔹 Kullanıcıya özel anahtar oluştur
  /// - Local storage üzerinde veri çakışmalarını önler
  String _getUserKey(String key) {
    return _currentUserId != null ? '${_currentUserId}_$key' : key;
  }

  // ===================== FIRESTORE İŞLEMLERİ =====================

  /// 🔹 Firestore’dan kullanıcı bilgilerini al
  Future<AppUser?> getUserDataFromFirestore() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          id: firebaseUser.uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          age: data['age'] ?? 0,
        );
      }
      return null;
    } catch (e) {
      print('Firestore kullanıcı verisi alma hatası: $e');
      return null;
    }
  }

  /// 🔹 Firestore’a kullanıcı bilgilerini kaydet
  Future<void> saveUserDataToFirestore(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'age': user.age,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore kullanıcı verisi kaydetme hatası: $e');
      throw e;
    }
  }

  // ===================== LOCAL STORAGE İŞLEMLERİ =====================

  /// 🔹 Öneri kaydet
  Future<void> saveRecommendation(String recommendation) async {
    final key = _getUserKey('recommendations');
    List<String> recs = _prefs?.getStringList(key) ?? [];
    recs.add(recommendation);
    await _prefs?.setStringList(key, recs);
  }

  /// 🔹 Önerileri al
  List<String> getRecommendations() {
    final key = _getUserKey('recommendations');
    return _prefs?.getStringList(key) ?? [];
  }

  /// 🔹 Şeker ölçümlerini kaydet
  Future<void> saveBloodSugarRecords(List<Map<String, dynamic>> records) async {
    final List<String> stringList = records.map((record) =>
      '${record['value']},${record['time'].millisecondsSinceEpoch}').toList();
    await _prefs?.setStringList(_getUserKey('blood_sugar_records'), stringList);
  }

  /// 🔹 Şeker ölçümlerini al
  List<Map<String, dynamic>> getBloodSugarRecords() {
    final List<String>? stringList = _prefs?.getStringList(_getUserKey('blood_sugar_records'));
    if (stringList == null) return [];

    return stringList.map((String str) {
      final parts = str.split(',');
      return {
        'value': int.parse(parts[0]),
        'time': DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1]))
      };
    }).toList();
  }

  /// 🔹 Tansiyon ölçümlerini kaydet
  Future<void> saveBloodPressure(List<List<int?>> bloodPressure) async {
    final List<String> stringList = bloodPressure.map((bp) =>
      '${bp[0] ?? ''},${bp[1] ?? ''}').toList();
    await _prefs?.setStringList(_getUserKey('blood_pressure'), stringList);
  }

  /// 🔹 Tansiyon ölçümlerini al
  List<List<int?>> getBloodPressure() {
    final List<String>? stringList = _prefs?.getStringList(_getUserKey('blood_pressure'));
    if (stringList == null) return List.generate(5, (_) => [null, null]);

    return stringList.map((String str) {
      final parts = str.split(',');
      return [
        parts[0].isEmpty ? null : int.parse(parts[0]),
        parts[1].isEmpty ? null : int.parse(parts[1])
      ];
    }).toList();
  }

  /// 🔹 Mevcut kullanıcıya ait tüm local verileri temizle
  Future<void> clearCurrentUserData() async {
    if (_currentUserId != null) {
      await _prefs?.remove(_getUserKey('blood_sugar_records'));
      await _prefs?.remove(_getUserKey('blood_pressure'));
    }
  }

  /// 🔹 Tüm kullanıcıların local verilerini temizle (debug amaçlı)
  Future<void> clearAllUsersData() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.contains('_blood_sugar_records') || key.contains('_blood_pressure')) {
        await _prefs?.remove(key);
      }
    }
  }
}
