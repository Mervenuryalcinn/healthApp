// diabetes_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:health_app/services/api_service.dart';

class DiabetesPredictionScreen extends StatefulWidget {
  @override
  _DiabetesPredictionScreenState createState() => _DiabetesPredictionScreenState();
}

class _DiabetesPredictionScreenState extends State<DiabetesPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form değişkenleri
  String _gender = 'Female';
  String _smokingHistory = 'never';
  double _age = 30;
  int _hypertension = 0;
  int _heartDisease = 0;
  double _bmi = 22.0;
  double _hba1cLevel = 5.0;
  double _bloodGlucoseLevel = 100;

  // Cinsiyet seçenekleri
  final List<String> _genders = ['Female', 'Male', 'Other'];

  // Sigara kullanımı seçenekleri
  final List<String> _smokingOptions = [
    'never', 'former', 'current', 'not current', 'ever', 'No Info'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tip 2 Diyabet Tahmini'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lütfen sağlık bilgilerinizi girin:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Cinsiyet seçimi
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'Female' ? 'Kadın' :
                    value == 'Male' ? 'Erkek' : 'Diğer'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Cinsiyet',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Yaş
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Yaş',
                  border: OutlineInputBorder(),
                ),
                initialValue: _age.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen yaşınızı girin';
                  if (double.tryParse(value) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
                onSaved: (value) {
                  _age = double.parse(value!);
                },
              ),
              SizedBox(height: 15),

              // Hipertansiyon
              DropdownButtonFormField<int>(
                value: _hypertension,
                items: [
                  DropdownMenuItem(value: 0, child: Text('Hayır')),
                  DropdownMenuItem(value: 1, child: Text('Evet')),
                ],
                onChanged: (newValue) {
                  setState(() {
                    _hypertension = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Hipertansiyon var mı?',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Kalp Hastalığı
              DropdownButtonFormField<int>(
                value: _heartDisease,
                items: [
                  DropdownMenuItem(value: 0, child: Text('Hayır')),
                  DropdownMenuItem(value: 1, child: Text('Evet')),
                ],
                onChanged: (newValue) {
                  setState(() {
                    _heartDisease = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kalp hastalığı var mı?',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Sigara Kullanımı
              DropdownButtonFormField<String>(
                value: _smokingHistory,
                items: _smokingOptions.map((String value) {
                  String displayText;
                  switch(value) {
                    case 'never': displayText = 'Hiç kullanmadım'; break;
                    case 'former': displayText = 'Eskiden kullanıyordum'; break;
                    case 'current': displayText = 'Şu anda kullanıyorum'; break;
                    case 'not current': displayText = 'Şu anda kullanmıyorum'; break;
                    case 'ever': displayText = 'Hiç'; break;
                    case 'No Info': displayText = 'Bilgi yok'; break;
                    default: displayText = value;
                  }
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _smokingHistory = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Sigara kullanım durumu',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // BMI
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Vücut Kitle İndeksi (BMI)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _bmi.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen BMI değerinizi girin';
                  if (double.tryParse(value) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
                onSaved: (value) {
                  _bmi = double.parse(value!);
                },
              ),
              SizedBox(height: 15),

              // HbA1c Seviyesi
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'HbA1c Seviyesi',
                  border: OutlineInputBorder(),
                ),
                initialValue: _hba1cLevel.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen HbA1c seviyenizi girin';
                  if (double.tryParse(value) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
                onSaved: (value) {
                  _hba1cLevel = double.parse(value!);
                },
              ),
              SizedBox(height: 15),

              // Kan Şekeri Seviyesi
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kan Şekeri Seviyesi (mg/dL)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _bloodGlucoseLevel.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen kan şekeri seviyenizi girin';
                  if (double.tryParse(value) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
                onSaved: (value) {
                  _bloodGlucoseLevel = double.parse(value!);
                },
              ),
              SizedBox(height: 25),

              // Tahmin Yap Butonu
              ElevatedButton(
                onPressed: _predictDiabetes,
                child: Text('Tahmin Yap'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _predictDiabetes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final predictionData = {
          'gender': _gender,
          'age': _age,
          'hypertension': _hypertension,
          'heart_disease': _heartDisease,
          'smoking_history': _smokingHistory,
          'bmi': _bmi,
          'HbA1c_level': _hba1cLevel,
          'blood_glucose_level': _bloodGlucoseLevel,
          'diabetes': 0,  // Zorunlu alan backend için
        };

        final response = await ApiService.predictDiabetes(predictionData);

        if (response['success'] == true && response['result'] != null) {
          _showPredictionResult(response);
        } else {
          final errorMsg = response['error'] ?? 'Bilinmeyen bir hata';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tahmin yapılırken hata: $errorMsg')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPredictionResult(Map<String, dynamic> response) {
    final result = response['result'] ?? {};
    final recommendations = response['recommendations'] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tahmin Sonucu'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Diyabet Riski: ${result['risk_percentage'] ?? 0}%'),
                SizedBox(height: 10),
                Text('Öneriler:'),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recommendations.map<Widget>((rec) =>
                      Text('• $rec')).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
