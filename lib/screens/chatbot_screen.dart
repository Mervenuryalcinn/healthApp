import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class ChatbotScreen extends StatefulWidget {
  final AppUser? user;
  final List<List<int?>>? bloodPressure;
  final List<Map<String, dynamic>>? bloodSugar;

  // Tüm parametreler opsiyonel — HomeScreen'de argüman vermezsen StorageService'den alırız.
  ChatbotScreen({Key? key, this.user, this.bloodPressure, this.bloodSugar}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user'|'bot', 'text': '...'}
  AppUser? _user;
  List<List<int?>> _bp = List.generate(5, (_) => [null, null]);
  List<Map<String, dynamic>> _sugar = [];
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    // Eğer widget parametreleri verilmemişse StorageService'ten çek
    _initData();
  }

  Future<void> _initData() async {
    // öncelik: widget üzerinden gelen veri, yoksa StorageService
    _user = widget.user ?? await _storage.getUserDataFromFirestore() ?? null;
    final bpFromStorage = widget.bloodPressure ?? _storage.getBloodPressure();
    final sugarFromStorage = widget.bloodSugar ?? _storage.getBloodSugarRecords();

    setState(() {
      if (bpFromStorage.isNotEmpty) _bp = bpFromStorage;
      if (sugarFromStorage.isNotEmpty) _sugar = sugarFromStorage;
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });
    _controller.clear();
    _replyTo(text);
  }

  void _replyTo(String input) {
    // Basit anahtar kelime tabanlı cevaplama (yerine gerçek modele REST çağrısı ekleyebilirsin)
    final lower = input.toLowerCase();
    String reply;

    if (lower.contains('şeker') || lower.contains('kan şekeri') || lower.contains('açlık')) {
      if (_sugar.isNotEmpty) {
        final latest = _sugar.last['value'];
        final time = _sugar.last['time'];
        final timeStr = time is DateTime ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : '';
        reply = 'Son şeker ölçümünüz: $latest mg/dL ${timeStr.isNotEmpty ? ' ($timeStr)' : ''}.';
      } else {
        reply = 'Henüz kayıtlı bir şeker ölçümünüz yok.';
      }
    } else if (lower.contains('tansiyon') || lower.contains('kan basıncı')) {
      final recent = _bp.where((e) => e[0] != null && e[1] != null).toList();
      if (recent.isNotEmpty) {
        final last = recent.last;
        reply = 'En son tansiyonunuz: ${last[0]}/${last[1]} mmHg.';
      } else {
        reply = 'Henüz kayıtlı bir tansiyon veriniz yok.';
      }
    } else if (lower.contains('diyabet') || lower.contains('risk')) {
      // Basit kural tabanlı tahmin (yerine gerçek model çağır)
      int riskScore = 0;
      if (_sugar.isNotEmpty) {
        final latest = _sugar.last['value'];
        if (latest is int && latest > 125) riskScore += 2;
        else if (latest is int && latest > 100) riskScore += 1;
      }
      if (_user != null && _user!.age >= 45) riskScore += 1;
      final highBp = _bp.any((e) => e[0] != null && e[1] != null && (e[0]! > 140 || e[1]! > 90));
      if (highBp) riskScore += 1;

      if (riskScore >= 3) reply = 'Dikkat: Mevcut veriler yüksek diyabet riski işaret ediyor. Bir sağlık kuruluşuna başvurmanızı öneririm.';
      else if (riskScore == 2) reply = 'Orta düzey risk. Yaşam tarzı değişiklikleri ve bir kontrol önerilir.';
      else reply = 'Düşük risk görünüyor, ancak düzenli takip iyi olur.';
      reply += '\n(Not: Bu sadece basit bir kural tabanlı öneridir, kesin tanı değildir.)';
    } else if (lower.contains('merhaba') || lower.contains('selam')) {
      reply = 'Merhaba${_user != null ? ' ${_user!.name}' : ''}! Sağlık verilerinize dair sorular sorabilirsiniz. Örnek: "son şeker değerim nedir?"';
    } else {
      reply =
      'Soruyu anlayamadım. Şeker, tansiyon veya diyabet riski ile ilgili sorular sorabilirsiniz.\nAyrıca model entegrasyonu isterseniz burada bir REST API çağrısı yapacak şekilde düzenleyebilirim.';
    }

    // Bot cevabı ekle
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _messages.add({'role': 'bot', 'text': reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sağlık ChatBot'),
        automaticallyImplyLeading: false, // bottom navigation içinde geri gerekmeyebilir
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                child: Text(
                  'Merhaba! Sağlık verilerinizle ilgili sorular sorabilirsiniz.\nÖrnek: "Son şeker ölçümüm nedir?"',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isUser = m['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m['text'] ?? ''),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Icon(Icons.send),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
