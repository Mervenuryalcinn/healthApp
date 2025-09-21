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
        title: Text('Profil'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Profil Bilgileri',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('İsim', _currentUser.name, Icons.person),
                    Divider(),
                    _buildInfoRow('E-posta', _currentUser.email, Icons.email),
                    Divider(),
                    _buildInfoRow('Yaş', _currentUser.age.toString(), Icons.cake),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Profil düzenleme ekranına yönlendirme ve sonucu bekleme
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: _currentUser),
                    ),
                  );

                  // Eğer kullanıcı bilgileri güncellendiyse, ana bileşeni bildir ve kendi state'ini güncelle
                  if (updatedUser != null && updatedUser is AppUser) {
                    setState(() {
                      _currentUser = updatedUser;
                    });
                    widget.onProfileUpdated(updatedUser);

                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profil bilgileriniz güncellendi'),
                          backgroundColor: Colors.green,
                        )
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text('Profili Düzenle', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}