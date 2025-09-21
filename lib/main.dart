import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_app/screens/login_screen.dart';
import 'package:health_app/screens/register_screen.dart';
import 'package:health_app/screens/home_screen.dart';
import 'package:health_app/services/auth_service.dart';
import 'package:health_app/models/user.dart';
import 'services/storage_service.dart';

/// 🔹 Uygulama başlangıç noktası
/// - Firebase ve StorageService başlatılır
/// - Kullanıcının daha önce giriş yapıp yapmadığı kontrol edilir
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase başlat
  await Firebase.initializeApp();
  // StorageService singleton başlat
  final storageService = StorageService();
  await storageService.init();
  // Uygulamayı başlat
  runApp(HealthApp());
}
/// 🔹 HealthApp
/// - MaterialApp yapılandırması ve ana routing
/// - FutureBuilder ile mevcut kullanıcı kontrolü yapılır
class HealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sağlık Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      /// 🔹 Ana ekran belirleme
      /// - Kullanıcı daha önce giriş yapmışsa HomeScreen'e yönlendir
      /// - Aksi halde LoginScreen göster
      home: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!['id'] != null) {
              // Kullanıcı bilgisi mevcut
              AppUser user = AppUser.fromJson(snapshot.data!);
              return HomeScreen(user: user); // HomeScreen'e user nesnesi gönderiliyor
            } else {
              // Kullanıcı yoksa giriş ekranı
              return LoginScreen();
            }
          }
          // Veri yükleniyor ekranı
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      /// 🔹 Route tanımları
      /// - Login ve Register ekranları için
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        // '/home' route opsiyonel, FutureBuilder ile kontrol sağlanıyor
      },
    );
  }
}
