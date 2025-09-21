import 'package:flutter/material.dart';

// Kullanıcıdan kan şekeri ve tansiyon verilerini almak için oluşturulmuş ekran (Stateful Widget)
class DataInputScreen extends StatefulWidget {
  // Kan şekeri verisi (isteğe bağlı)
  final int? bloodSugar;

  // 5 güne ait tansiyon verileri (her gün için sistolik ve diyastolik değerler)
  final List<List<int?>> bloodPressure;

  // Constructor: bloodSugar opsiyonel, bloodPressure zorunlu
  DataInputScreen({this.bloodSugar, required this.bloodPressure});

  @override
  _DataInputScreenState createState() => _DataInputScreenState();
}

class _DataInputScreenState extends State<DataInputScreen> {
  // Formun doğrulama anahtarı
  final _formKey = GlobalKey<FormState>();

  // Text alanları için kontrolcüler (kullanıcıdan alınan değerleri okumak için)
  TextEditingController _sugarController = TextEditingController();
  TextEditingController _systolicController = TextEditingController();
  TextEditingController _diastolicController = TextEditingController();

  // Kullanıcının seçtiği gün (0–4 arası değer alır)
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    // Eğer kan şekeri değeri daha önce girilmişse, text alanına yazdırılır
    if (widget.bloodSugar != null) {
      _sugarController.text = widget.bloodSugar.toString();
    }
  }

  // Kaydet butonuna basıldığında çalışan fonksiyon
  void _saveData() {
    // Form doğrulaması başarılıysa
    if (_formKey.currentState!.validate()) {
      // Text alanları boş değilse, girilen değeri int'e çevir, boşsa null bırak
      final int? sugar = _sugarController.text.isNotEmpty
          ? int.parse(_sugarController.text)
          : null;

      final int? systolic = _systolicController.text.isNotEmpty
          ? int.parse(_systolicController.text)
          : null;

      final int? diastolic = _diastolicController.text.isNotEmpty
          ? int.parse(_diastolicController.text)
          : null;

      // Geriye dönülürken (Navigator.pop) girilen veriler bir Map olarak gönderilir
      Navigator.pop(context, {
        'bloodSugar': sugar,
        // Eğer hem sistolik hem diyastolik girilmişse tansiyon verisini de ekle
        'bloodPressure': systolic != null && diastolic != null
            ? {'day': _selectedDay, 'systolic': systolic, 'diastolic': diastolic}
            : null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst bar başlığı
      appBar: AppBar(title: Text("Değer Gir")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Formun doğrulama anahtarı
          child: Column(
            children: [
              // Kan şekeri giriş alanı
              TextFormField(
                controller: _sugarController,
                decoration: InputDecoration(labelText: "Kan Şekeri (mg/dL)"),
                keyboardType: TextInputType.number, // Sadece sayı girişi
              ),
              // Sistolik (büyük tansiyon) giriş alanı
              TextFormField(
                controller: _systolicController,
                decoration: InputDecoration(labelText: "Sistolik (Büyük)"),
                keyboardType: TextInputType.number,
              ),
              // Diyastolik (küçük tansiyon) giriş alanı
              TextFormField(
                controller: _diastolicController,
                decoration: InputDecoration(labelText: "Diyastolik (Küçük)"),
                keyboardType: TextInputType.number,
              ),
              // Gün seçimi için açılır menü
              DropdownButton<int>(
                value: _selectedDay,
                items: List.generate(
                  5, // Toplam 5 gün
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text("Gün ${i + 1}"),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedDay = val!; // Seçilen günü kaydet
                  });
                },
              ),
              SizedBox(height: 20),
              // Kaydet butonu
              ElevatedButton(
                onPressed: _saveData,
                child: Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
