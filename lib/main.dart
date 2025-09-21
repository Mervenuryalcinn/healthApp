import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_app/screens/login_screen.dart';
import 'package:health_app/screens/register_screen.dart';
import 'package:health_app/screens/home_screen.dart';
import 'package:health_app/services/auth_service.dart';
import 'package:health_app/models/user.dart';
import 'services/storage_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // StorageService'i başlat
  await Firebase.initializeApp();
  final storageService = StorageService();
  await storageService.init();

  runApp(HealthApp());
}

class HealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sağlık Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!['id'] != null) {
              AppUser user = AppUser.fromJson(snapshot.data!);
              return HomeScreen(user: user); // Burada user gönderiyoruz
            } else {
              return LoginScreen();
            }
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        // '/home' route is optional, direkt FutureBuilder ile yönetiyoruz
      },
    );
  }
}
