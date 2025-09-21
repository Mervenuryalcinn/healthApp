import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Giriş yap
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final fb.UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);
      await prefs.setString('user', json.encode(userData));

      return {'success': true, 'user': userData};
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Kayıt ol
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, int age) async {
    try {
      final fb.UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final userData = {
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'age': age,
      };

      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);
      await prefs.setString('user', json.encode(userData));

      return {'success': true, 'user': userData};
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Çıkış yap
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// Kullanıcı giriş yapmış mı kontrol et
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = _auth.currentUser;
    return prefs.containsKey('token') && currentUser != null;
  }

  /// Mevcut kullanıcıyı getir
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) return json.decode(userString);
    return null;
  }

  /// Firebase hatalarını kullanıcı dostu mesajla çevir
  static String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanılıyor';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      default:
        return 'Bir hata oluştu: $code';
    }
  }
}
