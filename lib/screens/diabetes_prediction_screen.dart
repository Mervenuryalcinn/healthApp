// diabetes_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:health_app/services/api_service.dart';

// Diyabet tahmini yapmak için kullanılan ana ekran widget'ı
class DiabetesPredictionScreen extends StatefulWidget {
  @override
  _DiabetesPredictionScreenState createState() => _DiabetesPredictionScreenState();
}

// Ekranın state yönetimini sağlayan sınıf
class _DiabetesPredictionScreenState extends State<DiabetesPredictionScreen> {
  // Form durumunu yönetmek için global anahtar
  final _formKey = GlobalKey<FormState>();
  // Yüklenme durumunu takip eden değişken
  bool _isLoading = false;

  // Form değişkenleri - kullanıcı girdilerini tutar
  String _gender = 'Female'; // Varsayılan cinsiyet
  String _smokingHistory = 'never'; // Varsayılan sigara kullanım durumu
  double _age = 30; // Varsayılan yaş
  int _hypertension = 0; // Hipertansiyon durumu (0: Hayır, 1: Evet)
  int _heartDisease = 0; // Kalp hastalığı durumu (0: Hayır, 1: Evet)
  double _bmi = 22.0; // Vücut kitle indeksi
  double _hba1cLevel = 5.0; // HbA1c seviyesi
  double _bloodGlucoseLevel = 100; // Kan şekeri seviyesi

  // BMI alanını kontrol etmek için controller
  final TextEditingController _bmiController = TextEditingController();

  // Cinsiyet seçenekleri listesi
  final List<String> _genders = ['Female', 'Male', 'Other'];

  // Sigara kullanımı seçenekleri listesi
  final List<String> _smokingOptions = [
    'never', 'former', 'current', 'not current', 'ever', 'No Info'
  ];

  @override
  void initState() {
    super.initState();
    // BMI controller'ı varsayılan değerle başlat
    _bmiController.text = _bmi.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tip 2 Diyabet Tahmini', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // Yüklenme durumuna göre farklı arayüz göster
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
            SizedBox(height: 16),
            Text(
              'Tahmin yapılıyor...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      )
          : Container(
        // Arkaplan gradient efekti
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bilgilendirme kartı
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Lütfen sağlık bilgilerinizi girin:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Cinsiyet seçimi bölümü
                _buildSectionTitle('Kişisel Bilgiler'),
                _buildDropdown(
                  value: _gender,
                  items: _genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Female' ? 'Kadın' :
                        value == 'Male' ? 'Erkek' : 'Diğer',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                  label: 'Cinsiyet',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 15),

                // Yaş giriş alanı
                _buildTextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  initialValue: _age.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Lütfen yaşınızı girin';
                    if (double.tryParse(value) == null)
                      return 'Geçerli bir sayı girin';
                    return null;
                  },
                  onSaved: (value) {
                    _age = double.parse(value!);
                  },
                ),
                SizedBox(height: 15),

                // Sağlık durumu bölümü
                _buildSectionTitle('Sağlık Durumu'),
                // Hipertansiyon durumu seçimi
                _buildDropdown(
                  value: _hypertension,
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Hayır', style: TextStyle(fontSize: 16)),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Evet', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _hypertension = newValue!;
                    });
                  },
                  label: 'Hipertansiyon var mı?',
                  icon: Icons.monitor_heart_outlined,
                ),
                SizedBox(height: 15),

                // Kalp Hastalığı durumu seçimi
                _buildDropdown(
                  value: _heartDisease,
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Hayır', style: TextStyle(fontSize: 16)),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Evet', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _heartDisease = newValue!;
                    });
                  },
                  label: 'Kalp hastalığı var mı?',
                  icon: Icons.favorite_border,
                ),
                SizedBox(height: 15),

                // Sigara Kullanımı durumu seçimi
                _buildDropdown(
                  value: _smokingHistory,
                  items: _smokingOptions.map((String value) {
                    String displayText;
                    switch (value) {
                      case 'never':
                        displayText = 'Hiç kullanmadım';
                        break;
                      case 'former':
                        displayText = 'Eskiden kullanıyordum';
                        break;
                      case 'current':
                        displayText = 'Şu anda kullanıyorum';
                        break;
                      case 'not current':
                        displayText = 'Şu anda kullanmıyorum';
                        break;
                      case 'ever':
                        displayText = 'Hiç';
                        break;
                      case 'No Info':
                        displayText = 'Bilgi yok';
                        break;
                      default:
                        displayText = value;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayText, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _smokingHistory = newValue!;
                    });
                  },
                  label: 'Sigara kullanım durumu',
                  icon: Icons.smoking_rooms_outlined,
                ),
                SizedBox(height: 15),

                // Vücut değerleri bölümü
                _buildSectionTitle('Vücut Değerleri'),
                // BMI giriş alanı ve hesaplayıcı butonu
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bmiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Vücut Kitle İndeksi (BMI)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Lütfen BMI değerinizi girin';
                          if (double.tryParse(value) == null)
                            return 'Geçerli bir sayı girin';
                          return null;
                        },
                        onSaved: (value) {
                          _bmi = double.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // BMI hesaplayıcı butonu
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal,
                      ),
                      child: IconButton(
                        onPressed: _openBmiCalculator,
                        icon: Icon(Icons.calculate_outlined, color: Colors.white),
                        tooltip: "BMI Hesaplayıcı",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // HbA1c Seviyesi giriş alanı
                _buildTextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'HbA1c Seviyesi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  initialValue: _hba1cLevel.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Lütfen HbA1c seviyenizi girin';
                    if (double.tryParse(value) == null)
                      return 'Geçerli bir sayı girin';
                    return null;
                  },
                  onSaved: (value) {
                    _hba1cLevel = double.parse(value!);
                  },
                ),
                SizedBox(height: 15),

                // Kan Şekeri Seviyesi giriş alanı
                _buildTextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kan Şekeri Seviyesi (mg/dL)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.monitor_heart_outlined),
                  ),
                  initialValue: _bloodGlucoseLevel.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Lütfen kan şekeri seviyenizi girin';
                    if (double.tryParse(value) == null)
                      return 'Geçerli bir sayı girin';
                    return null;
                  },
                  onSaved: (value) {
                    _bloodGlucoseLevel = double.parse(value!);
                  },
                ),
                SizedBox(height: 25),

                // Tahmin Yap butonu
                Container(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _predictDiabetes,
                    child: Text(
                      'Tahmin Yap',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bölüm başlığı oluşturan yardımcı metod
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.teal.shade700,
        ),
      ),
    );
  }

  // Dropdown menü oluşturan yardımcı metod
  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
    required String label,
    required IconData icon,
  }) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon),
      ),
      borderRadius: BorderRadius.circular(10),
      icon: Icon(Icons.arrow_drop_down_circle_outlined),
      isExpanded: true,
    );
  }

  // Metin giriş alanı oluşturan yardımcı metod
  Widget _buildTextField({
    required TextInputType keyboardType,
    required InputDecoration decoration,
    required String initialValue,
    required String? Function(String?) validator,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: decoration,
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
    );
  }

  // BMI hesaplayıcıyı açan metod
  void _openBmiCalculator() {
    final weightController = TextEditingController();
    final heightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BMI Hesaplayıcı",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                SizedBox(height: 20),
                // Kilo giriş alanı
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Kilo (kg)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.fitness_center_outlined),
                  ),
                ),
                SizedBox(height: 10),
                // Boy giriş alanı
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Boy (cm)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.height_outlined),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // İptal butonu
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "İptal",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Hesapla butonu
                    ElevatedButton(
                      onPressed: () {
                        final weight = double.tryParse(weightController.text);
                        final height = double.tryParse(heightController.text);

                        if (weight != null && height != null && height > 0) {
                          // BMI hesaplama formülü: kg / (m^2)
                          final bmi = weight / ((height / 100) * (height / 100));

                          setState(() {
                            _bmi = double.parse(bmi.toStringAsFixed(1));
                            _bmiController.text = _bmi.toString();
                          });

                          Navigator.pop(context);

                          // Hesaplanan BMI değerini gösteren snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('BMI değeriniz: $_bmi'),
                              backgroundColor: Colors.teal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else {
                          // Hatalı giriş durumunda hata mesajı
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lütfen geçerli değerler giriniz'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Hesapla"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Diyabet tahmini yapan metod
  void _predictDiabetes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // API'ye gönderilecek veri seti
        final predictionData = {
          'gender': _gender,
          'age': _age,
          'hypertension': _hypertension,
          'heart_disease': _heartDisease,
          'smoking_history': _smokingHistory,
          'bmi': _bmi,
          'HbA1c_level': _hba1cLevel,
          'blood_glucose_level': _bloodGlucoseLevel,
          'diabetes': 0, // Zorunlu alan backend için
        };

        // API servisini çağır
        final response = await ApiService.predictDiabetes(predictionData);

        if (response['success'] == true && response['result'] != null) {
          // Başarılı yanıt durumunda sonucu göster
          _showPredictionResult(response);
        } else {
          // Hata durumunda hata mesajını göster
          final errorMsg = response['error'] ?? 'Bilinmeyen bir hata';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tahmin yapılırken hata: $errorMsg'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        // Beklenmeyen hata durumunda
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Tahmin sonucunu gösteren metod
  void _showPredictionResult(Map<String, dynamic> response) {
    final result = response['result'] ?? {};
    final recommendations = response['recommendations'] ?? [];
    final riskLevel = result['risk_level'] ?? "Bilinmiyor";

    // Risk seviyesine göre renk belirleme
    Color riskColor;
    if (riskLevel.contains('Düşük')) {
      riskColor = Colors.green;
    } else if (riskLevel.contains('Orta')) {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.red;
    }

    // Sonuçları gösteren dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Risk seviyesine göre ikon gösterimi
                Center(
                  child: Icon(
                    riskColor == Colors.green ? Icons.check_circle_outline :
                    riskColor == Colors.orange ? Icons.warning_amber_outlined :
                    Icons.error_outline,
                    color: riskColor,
                    size: 50,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Tahmin Sonucu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Diyabet Riski:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Risk seviyesi metni
                Center(
                  child: Text(
                    riskLevel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Öneriler başlığı
                Text(
                  'Öneriler:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                // Öneriler listesi
                ...recommendations.map<Widget>((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                SizedBox(height: 20),
                // Tamam butonu
                Center(
                  child: ElevatedButton(
                    child: Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
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
      },
    );
  }
}