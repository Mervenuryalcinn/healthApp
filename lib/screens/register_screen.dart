import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Kullanıcının yeni hesap oluşturmasını sağlayan kayıt ekranı
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form anahtarı: doğrulama ve form durumunu yönetmek için
  final _formKey = GlobalKey<FormState>();

  // Metin alanı kontrolcüler
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ageController = TextEditingController();

  // Yükleniyor durumu ve şifre görünürlüğü
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Kayıt işlemini başlatır
  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Şifre ve tekrarının eşleşip eşleşmediğini kontrol et
      if (_passwordController.text != _confirmController.text) {
        Fluttertoast.showToast(msg: 'Şifreler eşleşmiyor', backgroundColor: Colors.red);
        return;
      }
      setState(() => _isLoading = true);

      // AuthService üzerinden kayıt isteği gönder
      final result = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        int.tryParse(_ageController.text.trim()) ?? 0,
      );

      setState(() => _isLoading = false);

      // Sonuca göre kullanıcıyı bilgilendir
      if (result['success']) {
        Fluttertoast.showToast(msg: 'Kayıt başarılı! Giriş yapabilirsiniz.');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        Fluttertoast.showToast(msg: result['error'] ?? 'Kayıt başarısız', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Arka plan gradyanı
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  // Üstte sağlık ikonu
                  Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  // Başlık
                  Text(
                    'Yeni Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Alt başlık
                  Text(
                    'Sağlık takibine başlamak için kaydolun',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Kayıt formu kartı
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Ad Soyad alanı
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Ad Soyad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.person, color: Color(0xFF2D6A4F)),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: (v) => v!.isEmpty ? 'Ad girin' : null,
                          ),
                          SizedBox(height: 16),
                          // E-posta alanı
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'E-posta',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.email, color: Color(0xFF2D6A4F)),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: (v) => v!.contains('@') ? null : 'Geçerli e-posta girin',
                          ),
                          SizedBox(height: 16),
                          // Yaş alanı
                          TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Yaş',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.cake, color: Color(0xFF2D6A4F)),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || int.tryParse(v) == null) ? 'Yaş girin' : null,
                          ),
                          SizedBox(height: 16),
                          // Şifre alanı
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF2D6A4F)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Şifre en az 6 karakter' : null,
                          ),
                          SizedBox(height: 16),
                          // Şifre tekrar alanı
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre Tekrar',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2D6A4F)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: (v) => v!.isEmpty ? 'Şifre tekrar' : null,
                          ),
                          SizedBox(height: 30),
                          // Kayıt butonu veya yüklenme göstergesi
                          _isLoading
                              ? CircularProgressIndicator(color: Color(0xFF2D6A4F))
                              : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _register,
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white, // Beyaz yazı
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2D6A4F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Giriş ekranına yönlendirme
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Zaten hesabınız var mı? ',
                                style: TextStyle(color: Colors.grey[600]),
                                children: [
                                  TextSpan(
                                    text: 'Giriş yapın',
                                    style: TextStyle(
                                      color: Color(0xFF2D6A4F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
