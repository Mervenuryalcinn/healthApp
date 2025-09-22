import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'register_screen.dart';
// Bu sayfa kullanıcı girişi (login) ekranını temsil eder ve kullanıcıdan e-posta ile şifre alarak giriş işlemini gerçekleştirir.

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] && result['user'] != null) {
      Fluttertoast.showToast(
        msg: 'Giriş başarılı!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_SHORT,
      );

      final AppUser user = AppUser.fromJson(result['user']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
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
      resizeToAvoidBottomInset: true, // Klavye açılınca form scroll olsun
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
          ),
        ),
        child: SafeArea(
          bottom: false, // Alt boşluğu kaldır
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Icon(
                      Icons.health_and_safety,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sağlık Takip Uygulaması',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sağlığınızı takip etmek için giriş yapın',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-posta',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon:
                                Icon(Icons.email, color: Color(0xFF2D6A4F)),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              validator: (value) => (value == null ||
                                  !value.contains('@'))
                                  ? 'Geçerli e-posta girin'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon:
                                Icon(Icons.lock, color: Color(0xFF2D6A4F)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                              validator: (value) => (value == null ||
                                  value.length < 6)
                                  ? 'Şifre en az 6 karakter olmalı'
                                  : null,
                            ),
                            SizedBox(height: 24),
                            _isLoading
                                ? CircularProgressIndicator(
                                color: Color(0xFF2D6A4F))
                                : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _login,
                                child: Text(
                                  'Kayıt Ol', // TODO: Buradaki buton yazısı muhtemelen "Giriş Yap" olmalı
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white, // Beyaz yazı
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2D6A4F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterScreen()),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Hesabınız yok mu? ',
                                  style: TextStyle(color: Colors.grey[600]),
                                  children: [
                                    TextSpan(
                                      text: 'Kayıt olun',
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
                    Container(
                      height: 200, // Alt boşluğu gradient ile doldur
                      color: Color(0xFF1B4332),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}