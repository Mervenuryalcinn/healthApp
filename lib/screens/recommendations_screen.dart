import 'package:flutter/material.dart';
import '../services/storage_service.dart'; // Önerileri yerel depodan almak için servis

// Kullanıcıya öneriler (recommendations) listesini gösteren ekran
class RecommendationsScreen extends StatefulWidget {
  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  // StorageService üzerinden önerileri okuyacağız
  final StorageService _storageService = StorageService();

  // Ekranda gösterilecek öneriler listesi
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında önerileri yükle
    _loadRecommendations();
  }

  // Yerel depodan önerileri al ve ekrana yansıt
  void _loadRecommendations() {
    setState(() {
      _recommendations = _storageService.getRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Eğer hiç öneri yoksa bilgilendirme yazısı göster
    // Varsa ListView.builder ile önerileri kart şeklinde listele
    return _recommendations.isEmpty
        ? Center(child: Text('Önerileriniz yok'))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.blue), // Öneri simgesi
                  title: Text(_recommendations[index]),               // Öneri metni
                ),
              );
            },
          );
  }
}
