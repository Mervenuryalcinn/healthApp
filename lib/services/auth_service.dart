import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🔹 Firebase Auth ve Firestore örnekleri
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Giriş yap
  /// - [email] ve [password] ile Firebase Auth üzerinden giriş yapar
  /// - Firestore’dan kullanıcı bilgilerini alır ve SharedPreferences’a kaydeder
  /// - Başarılıysa {'success': true, 'user': userData} döner
  /// - Hata durumunda {'success': false, 'error': mesaj} döner
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final fb.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Firestore'dan kullanıcı bilgilerini çek
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Kullanıcı bilgilerini SharedPreferences’a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);
      await prefs.setString('user', json.encode(userData));

      return {'success': true, 'user': userData};
    } on fb.FirebaseAuthException catch (e) {
      // Firebase hatalarını kullanıcı dostu mesaj ile döndür
      return {'success': false, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 🔹 Kayıt ol
  /// - [name], [email], [password], [age] ile kullanıcı oluşturur
  /// - Firestore’a kullanıcı bilgilerini kaydeder
  /// - SharedPreferences’a token ve kullanıcı bilgilerini ekler
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

      // SharedPreferences’a kaydet
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

  /// 🔹 Çıkış yap
  /// - Firebase Auth ve SharedPreferences’tan token ve user bilgilerini siler
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// 🔹 Kullanıcı giriş yapmış mı kontrol et
  /// - Token ve Firebase kullanıcı varlığı kontrol edilir
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = _auth.currentUser;
    return prefs.containsKey('token') && currentUser != null;
  }

  /// 🔹 Mevcut kullanıcı bilgilerini getir
  /// - SharedPreferences’tan kullanıcıyı JSON olarak döner
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) return json.decode(userString);
    return null;
  }

  /// 🔹 Firebase hatalarını kullanıcı dostu mesajla çevirir
  /// - [code]: FirebaseAuthException kodu
  /// - Return: Türkçe açıklama mesajı
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
