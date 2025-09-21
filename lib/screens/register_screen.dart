import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmController.text) {
        Fluttertoast.showToast(msg: 'Şifreler eşleşmiyor', backgroundColor: Colors.red);
        return;
      }
      setState(() => _isLoading = true);

      final result = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        int.tryParse(_ageController.text.trim()) ?? 0,
      );

      setState(() => _isLoading = false);

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
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Yeni Hesap Oluştur', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Ad Soyad', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Ad girin' : null),
                SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()), validator: (v) => v!.contains('@') ? null : 'Geçerli e-posta girin'),
                SizedBox(height: 16),
                TextFormField(controller: _ageController, decoration: InputDecoration(labelText: 'Yaş', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => (v==null || int.tryParse(v)==null) ? 'Yaş girin' : null),
                SizedBox(height: 16),
                TextFormField(controller: _passwordController, decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()), obscureText: true, validator: (v) => (v==null || v.length<6) ? 'Şifre en az 6 karakter' : null),
                SizedBox(height: 16),
                TextFormField(controller: _confirmController, decoration: InputDecoration(labelText: 'Şifre Tekrar', border: OutlineInputBorder()), obscureText: true, validator: (v) => v!.isEmpty ? 'Şifre tekrar' : null),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _register, child: Text('Kayıt Ol'))),
                TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())), child: Text('Zaten hesabınız var mı? Giriş yapın'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
