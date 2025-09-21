import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';   // Firebase/Backend kullanıcı işlemleri
import 'login_screen.dart';              // Kayıt sonrası giriş ekranına yönlendirme

// Yeni kullanıcı kaydı için ekran
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form doğrulama anahtarı
  final _formKey = GlobalKey<FormState>();

  // Kullanıcıdan alınacak bilgiler için controller'lar
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ageController = TextEditingController();

  // Yüklenme durumunu göstermek için flag
  bool _isLoading = false;

  // Kayıt işlemini başlatan fonksiyon
  void _register() async {
    // Tüm form alanları geçerliyse devam et
    if (_formKey.currentState!.validate()) {
      // Şifre ve şifre tekrar kontrolü
      if (_passwordController.text != _confirmController.text) {
        Fluttertoast.showToast(
          msg: 'Şifreler eşleşmiyor',
          backgroundColor: Colors.red,
        );
        return;
      }

      // Ekranda yüklenme animasyonu göster
      setState(() => _isLoading = true);

      // AuthService üzerinden kayıt isteği gönder
      final result = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        int.tryParse(_ageController.text.trim()) ?? 0,
      );

      // Kayıt işlemi tamamlandığında yüklenme animasyonunu kapat
      setState(() => _isLoading = false);

      // Kayıt başarılıysa kullanıcıyı giriş ekranına yönlendir
      if (result['success']) {
        Fluttertoast.showToast(
          msg: 'Kayıt başarılı! Giriş yapabilirsiniz.',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        // Hata varsa kullanıcıya göster
        Fluttertoast.showToast(
          msg: result['error'] ?? 'Kayıt başarısız',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form doğrulama için
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Başlık
                Text(
                  'Yeni Hesap Oluştur',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Ad Soyad alanı
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Ad girin' : null,
                ),
                SizedBox(height: 16),

                // E-posta alanı
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.contains('@') ? null : 'Geçerli e-posta girin',
                ),
                SizedBox(height: 16),

                // Yaş alanı
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || int.tryParse(v) == null) ? 'Yaş girin' : null,
                ),
                SizedBox(height: 16),

                // Şifre alanı
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Şifre en az 6 karakter' : null,
                ),
                SizedBox(height: 16),

                // Şifre tekrar alanı
                TextFormField(
                  controller: _confirmController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Şifre tekrar' : null,
                ),
                SizedBox(height: 24),

                // Kayıt butonu veya yüklenme animasyonu
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: Text('Kayıt Ol'),
                        ),
                      ),

                // Giriş ekranına yönlendirme butonu
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  ),
                  child: Text('Zaten hesabınız var mı? Giriş yapın'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
