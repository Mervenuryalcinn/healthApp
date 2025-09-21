import 'package:flutter/material.dart';

class DataInputScreen extends StatefulWidget {
  final int? bloodSugar;
  final List<List<int?>> bloodPressure;

  DataInputScreen({this.bloodSugar, required this.bloodPressure});

  @override
  _DataInputScreenState createState() => _DataInputScreenState();
}

class _DataInputScreenState extends State<DataInputScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _sugarController = TextEditingController();
  TextEditingController _systolicController = TextEditingController();
  TextEditingController _diastolicController = TextEditingController();
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    if (widget.bloodSugar != null) {
      _sugarController.text = widget.bloodSugar.toString();
    }
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      final int? sugar = _sugarController.text.isNotEmpty
          ? int.parse(_sugarController.text)
          : null;

      final int? systolic = _systolicController.text.isNotEmpty
          ? int.parse(_systolicController.text)
          : null;

      final int? diastolic = _diastolicController.text.isNotEmpty
          ? int.parse(_diastolicController.text)
          : null;

      Navigator.pop(context, {
        'bloodSugar': sugar,
        'bloodPressure': systolic != null && diastolic != null
            ? {'day': _selectedDay, 'systolic': systolic, 'diastolic': diastolic}
            : null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Değer Gir")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _sugarController,
                decoration: InputDecoration(labelText: "Kan Şekeri (mg/dL)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _systolicController,
                decoration: InputDecoration(labelText: "Sistolik (Büyük)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _diastolicController,
                decoration: InputDecoration(labelText: "Diyastolik (Küçük)"),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<int>(
                value: _selectedDay,
                items: List.generate(
                    5, (i) => DropdownMenuItem(value: i, child: Text("Gün ${i + 1}"))),
                onChanged: (val) {
                  setState(() {
                    _selectedDay = val!;
                  });
                },
              ),
              SizedBox(height: 20),
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
