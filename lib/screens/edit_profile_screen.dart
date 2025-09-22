import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

// EditProfileScreen: Kullanıcının profil bilgilerini (isim, e-posta, yaş) düzenleyebileceği ekran
class EditProfileScreen extends StatefulWidget {
  final AppUser user; // Mevcut kullanıcı bilgileri

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Form doğrulama anahtarı
  final _nameController = TextEditingController(); // İsim alanı kontrolcüsü
  final _emailController = TextEditingController(); // E-posta alanı kontrolcüsü
  final _ageController = TextEditingController(); // Yaş alanı kontrolcüsü
  final StorageService _storageService = StorageService(); // Firestore servis sınıfı

  bool _isLoading = false; // Yüklenme durumu (butonun animasyonu için)

  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcı bilgilerini text alanlarına aktar
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _ageController.text = widget.user.age.toString();
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları serbest bırak
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Kullanıcı profilini güncelleme fonksiyonu
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Kaydetme işlemi başlatıldığında loading aktif edilir
      });

      try {
        final firebaseUser = FirebaseAuth.instance.currentUser; // Giriş yapan kullanıcı

        if (firebaseUser != null) {
          // Yeni kullanıcı bilgileri ile model oluştur
          final updatedUser = AppUser(
            id: firebaseUser.uid,
            name: _nameController.text,
            email: _emailController.text,
            age: int.parse(_ageController.text),
          );

          // Firestore'a kaydet
          await _storageService.saveUserDataToFirestore(updatedUser);

          // Başarılı güncelleme mesajı
          Fluttertoast.showToast(
            msg: "Profil başarıyla güncellendi",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Güncellenmiş kullanıcıyı önceki sayfaya gönder
          Navigator.pop(context, updatedUser);
        } else {
          // Kullanıcı oturumu bulunamadığında hata mesajı
          Fluttertoast.showToast(
            msg: "Kullanıcı oturumu bulunamadı",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Beklenmeyen hata durumunda mesaj göster
        Fluttertoast.showToast(
          msg: "Bir hata oluştu: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        // İşlem tamamlandıktan sonra loading durumu kapatılır
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ekranın temel yapısı
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2D6A4F), // Uygulama ana rengi
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profil Fotoğrafı simgesi
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Color(0xFF2D6A4F).withOpacity(0.5), width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2D6A4F).withOpacity(0.2),
                    child: Icon(Icons.person, size: 60, color: Color(0xFF2D6A4F)),
                  ),
                ),
              ),
              SizedBox(height: 25),
              // Başlık metni
              Center(
                child: Text(
                  'Profil Bilgilerini Düzenle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Form Kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // İsim alanı
                        _buildTextField(
                            controller: _nameController,
                            label: 'İsim',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir isim girin';
                              }
                              return null;
                            }),
                        Divider(height: 30, thickness: 1),
                        // E-posta alanı
                        _buildTextField(
                            controller: _emailController,
                            label: 'E-posta',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir e-posta girin';
                              }
                              if (!value.contains('@')) {
                                return 'Geçerli bir e-posta girin';
                              }
                              return null;
                            }),
                        Divider(height: 30, thickness: 1),
                        // Yaş alanı
                        _buildTextField(
                            controller: _ageController,
                            label: 'Yaş',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen yaşınızı girin';
                              }
                              int? age = int.tryParse(value);
                              if (age == null || age < 1 || age > 150) {
                                return 'Geçerli bir yaş girin';
                              }
                              return null;
                            }),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 35),
              // Kaydet butonu
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D6A4F),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Değişiklikleri Kaydet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Tekrarlayan textfield bileşenini oluşturan yardımcı fonksiyon
  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
