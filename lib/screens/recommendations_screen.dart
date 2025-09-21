import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class RecommendationsScreen extends StatefulWidget {
  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final StorageService _storageService = StorageService();
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    setState(() {
      _recommendations = _storageService.getRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _recommendations.isEmpty
        ? Center(child: Text('Önerileriniz yok'))
        : ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.lightbulb, color: Colors.blue),
            title: Text(_recommendations[index]),
          ),
        );
      },
    );
  }
}
