// diabetes_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:health_app/services/api_service.dart';

// Tip 2 Diyabet tahmini için kullanıcıdan sağlık verilerini alan ekran
class DiabetesPredictionScreen extends StatefulWidget {
  @override
  _DiabetesPredictionScreenState createState() => _DiabetesPredictionScreenState();
}

class _DiabetesPredictionScreenState extends State<DiabetesPredictionScreen> {
  final _formKey = GlobalKey<FormState>(); // Form doğrulama anahtarı
  bool _isLoading = false; // API isteği sırasında yüklenme durumunu kontrol eder

  // Formda tutulacak değişkenler (kullanıcı verileri)
  String _gender = 'Female';          // Cinsiyet
  String _smokingHistory = 'never';   // Sigara kullanımı geçmişi
  double _age = 30;                    // Yaş
  int _hypertension = 0;               // Hipertansiyon var mı (0 = yok, 1 = var)
  int _heartDisease = 0;               // Kalp hastalığı var mı (0 = yok, 1 = var)
  double _bmi = 22.0;                  // Vücut kitle indeksi (BMI)
  double _hba1cLevel = 5.0;            // HbA1c seviyesi
  double _bloodGlucoseLevel = 100;     // Kan şekeri seviyesi (mg/dL)

  // Cinsiyet seçenekleri
  final List<String> _genders = ['Female', 'Male', 'Other'];

  // Sigara kullanım durumu seçenekleri
  final List<String> _smokingOptions = [
    'never', 'former', 'current', 'not current', 'ever', 'No Info'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tip 2 Diyabet Tahmini'), // Uygulama üst başlık
      ),
      // Eğer API isteği yapılıyorsa yüklenme animasyonu göster
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form doğrulama anahtarı
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lütfen sağlık bilgilerinizi girin:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // 🔹 Cinsiyet seçimi dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'Female' ? 'Kadın'
                          : value == 'Male' ? 'Erkek'
                          : 'Diğer',
                    ),
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

              // 🔹 Yaş giriş alanı
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Yaş',
                  border: OutlineInputBorder(),
                ),
                initialValue: _age.toString(), // Varsayılan değer
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

              // 🔹 Hipertansiyon var mı?
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

              // 🔹 Kalp hastalığı var mı?
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

              // 🔹 Sigara kullanım durumu
              DropdownButtonFormField<String>(
                value: _smokingHistory,
                items: _smokingOptions.map((String value) {
                  // Kullanıcıya gösterilecek Türkçe açıklama
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

              // 🔹 Vücut kitle indeksi (BMI)
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

              // 🔹 HbA1c seviyesi
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

              // 🔹 Kan şekeri seviyesi
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

              // 🔹 Tahmin Yap butonu
              ElevatedButton(
                onPressed: _predictDiabetes, // API isteğini başlatır
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

  // ✅ API isteği: Form verilerini backend'e gönderir ve sonucu alır
  void _predictDiabetes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Formdaki verileri değişkenlere kaydet
      setState(() {
        _isLoading = true; // Yüklenme animasyonu göster
      });

      try {
        // Backend'e gönderilecek veri
        final predictionData = {
          'gender': _gender,
          'age': _age,
          'hypertension': _hypertension,
          'heart_disease': _heartDisease,
          'smoking_history': _smokingHistory,
          'bmi': _bmi,
          'HbA1c_level': _hba1cLevel,
          'blood_glucose_level': _bloodGlucoseLevel,
          'diabetes': 0,  // Backend için gerekli sabit alan
        };

        // ApiService üzerinden tahmin isteği gönder
        final response = await ApiService.predictDiabetes(predictionData);

        // Backend yanıtı başarılıysa sonuç göster
        if (response['success'] == true && response['result'] != null) {
          _showPredictionResult(response);
        } else {
          final errorMsg = response['error'] ?? 'Bilinmeyen bir hata';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tahmin yapılırken hata: $errorMsg')),
          );
        }
      } catch (e) {
        // Ağ veya sunucu hatası
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Yüklenme animasyonu durdur
        });
      }
    }
  }

  // ✅ Tahmin sonucu ve önerileri kullanıcıya gösteren dialog
  void _showPredictionResult(Map<String, dynamic> response) {
    final result = response['result'] ?? {}; // Tahmin sonucu
    final recommendations = response['recommendations'] ?? []; // Backend önerileri

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tahmin Sonucu'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Diyabet risk yüzdesi
                Text('Diyabet Riski: ${result['risk_percentage'] ?? 0}%'),
                SizedBox(height: 10),
                Text('Öneriler:'),
                SizedBox(height: 10),
                // Öneriler listesi
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
                Navigator.of(context).pop(); // Dialog kapat
              },
            ),
          ],
        );
      },
    );
  }
}
