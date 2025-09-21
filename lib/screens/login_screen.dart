import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';       // Kullanıcı giriş işlemleri için servis
import '../models/user.dart';                // Giriş yapan kullanıcı modelini temsil eder
import 'home_screen.dart';                   // Başarılı giriş sonrası gidilecek ekran
import 'register_screen.dart';               // Kayıt olma ekranı

// Giriş ekranı (Stateful widget – form alanları ve loading state tutmak için)
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form doğrulaması için key
  final _formKey = GlobalKey<FormState>();
  // Kullanıcı giriş bilgilerini almak için controllerlar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Yükleniyor durumunu göstermek için
  bool _isLoading = false;

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller’ları serbest bırak
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kullanıcı giriş işlemini başlatan fonksiyon
  void _login() async {
    // Form doğrulaması başarısızsa işlemi durdur
    if (!_formKey.currentState!.validate()) return;

    // Yükleniyor spinner’ını göstermek için state güncelle
    setState(() => _isLoading = true);

    // AuthService üzerinden giriş isteği gönder
    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Widget hala ekranda mı kontrolü (async işlemler için güvenlik)
    if (!mounted) return;

    // Yükleniyor spinner’ını kapat
    setState(() => _isLoading = false);

    // Giriş başarılıysa
    if (result['success'] && result['user'] != null) {
      // Kullanıcıya kısa başarı mesajı göster
      Fluttertoast.showToast(
        msg: 'Giriş başarılı!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_SHORT,
      );

      // JSON verisini AppUser modeline çevir
      final AppUser user = AppUser.fromJson(result['user']);
      // Ana ekrana yönlendir ve giriş ekranını kapat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
      // Hata durumunda kırmızı toast mesajı göster
      Fluttertoast.showToast(
        msg: result['error'] ?? 'Giriş başarısız',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form doğrulama için key
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Başlık
                Text(
                  'Sağlık Takip Uygulaması',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // E-posta giriş alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                    (value == null || !value.contains('@'))
                      ? 'Geçerli e-posta girin'
                      : null,
                ),
                SizedBox(height: 16),

                // Şifre giriş alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Şifre gizli gösterilir
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                    (value == null || value.length < 6)
                      ? 'Şifre en az 6 karakter olmalı'
                      : null,
                ),
                SizedBox(height: 24),

                // Giriş butonu veya yükleniyor göstergesi
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                SizedBox(height: 16),

                // Kayıt ekranına yönlendirme butonu
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  ),
                  child: Text('Hesabınız yok mu? Kayıt olun'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
