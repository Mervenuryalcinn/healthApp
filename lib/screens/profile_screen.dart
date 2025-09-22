import 'package:flutter/material.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final Function(AppUser) onProfileUpdated;
  ProfileScreen({required this.user, required this.onProfileUpdated});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser _currentUser;
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2D6A4F), // Ana sayfa ile aynı renk
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil fotoğrafı bölümü
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF2D6A4F).withOpacity(0.5),
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2D6A4F).withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              // Başlık
              Center(
                child: Text(
                  'Profil Bilgileri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D6A4F),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Bilgi kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildInfoRow('İsim', _currentUser.name, Icons.person),
                      Divider(
                        thickness: 1,
                        height: 30,
                      ),
                      _buildInfoRow('E-posta', _currentUser.email, Icons.email),
                      Divider(
                        thickness: 1,
                        height: 30,
                      ),
                      _buildInfoRow('Yaş', _currentUser.age.toString(), Icons.cake),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35),
              // Düzenleme butonu
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: _currentUser),
                      ),
                    );

                    if (updatedUser != null && updatedUser is AppUser) {
                      setState(() {
                        _currentUser = updatedUser;
                      });
                      widget.onProfileUpdated(updatedUser);

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profil bilgileriniz başarıyla güncellendi'),
                            backgroundColor: Color(0xFF2D6A4F),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: Text(
                      'Profili Düzenle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Color(0xFF2D6A4F).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Bilgi satırları oluşturan yardımcı metod
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2D6A4F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF2D6A4F), size: 22),
          ),
          SizedBox(width: 18),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}