import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// Kullanıcının profil bilgilerini düzenleyebileceği ekran
class EditProfileScreen extends StatefulWidget {
  final AppUser user; // Düzenlenecek mevcut kullanıcı

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Form ve input kontrolleri
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final StorageService _storageService = StorageService(); // Firestore kayıt servisi

  bool _isLoading = false; // Güncelleme işlemi sırasında yükleme göstergesi

  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcı bilgilerini form alanlarına doldur
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _ageController.text = widget.user.age.toString();
  }

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller’ları serbest bırak
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Kullanıcı formu doğrulandıktan sonra Firestore ve FirebaseAuth üzerinde güncelleme yapar
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Yükleniyor göstergesini başlat
      });

      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? firebaseUser = auth.currentUser;

        if (firebaseUser != null) {
          print('DEBUG: Firestore güncellemesi başlıyor...');

          // Güncellenmiş kullanıcı nesnesi
          final updatedUser = AppUser(
            id: firebaseUser.uid,
            name: _nameController.text,
            email: _emailController.text,
            age: int.parse(_ageController.text),
          );

          // Firestore'a kaydet
          await _storageService.saveUserDataToFirestore(updatedUser);

          print('DEBUG: Firestore güncellemesi tamamlandı');

          // Başarılı işlem sonrası Toast mesajı
          Fluttertoast.showToast(
            msg: "Profil başarıyla güncellendi",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Önceki ekrana dön ve güncellenmiş bilgileri geri gönder
          Navigator.pop(context, updatedUser);
        } else {
          // Kullanıcı oturumu yoksa uyarı ver
          print('DEBUG: Firebase kullanıcısı null');
          Fluttertoast.showToast(
            msg: "Kullanıcı oturumu bulunamadı",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } on FirebaseException catch (e) {
        // Firestore hatalarını yakala
        print('DEBUG: Firestore hatası: ${e.code} - ${e.message}');
        Fluttertoast.showToast(
          msg: "Firestore hatası: ${e.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        // Diğer tüm hataları yakala
        print('DEBUG: Genel hata: $e');
        Fluttertoast.showToast(
          msg: "Bir hata oluştu: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        // İşlem bitince yükleniyor göstergesini kapat
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profili Düzenle'),
        actions: [
          // Kaydet butonu yerine yükleme animasyonu göster
          _isLoading
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _updateProfile, // Kaydet ikonuna basıldığında profil güncelle
                ),
        ],
      ),
      body: _isLoading
          // Yükleme sırasında tam ekran spinner
          ? Center(child: CircularProgressIndicator())
          // Form alanları
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    /// İsim alanı
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir isim girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    /// E-posta alanı
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir e-posta adresi girin';
                        }
                        if (!value.contains('@')) {
                          return 'Lütfen geçerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    /// Yaş alanı
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Yaş',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen yaşınızı girin';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Lütfen geçerli bir sayı girin';
                        }
                        if (int.parse(value) < 1 || int.parse(value) > 150) {
                          return 'Lütfen geçerli bir yaş girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    /// Kaydet butonu
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Değişiklikleri Kaydet'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
