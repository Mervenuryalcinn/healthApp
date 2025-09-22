import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// Sağlık verilerine (şeker, tansiyon) göre temel cevaplar üreten
/// basit bir sohbet ekranı.
class ChatbotScreen extends StatefulWidget {
  final AppUser? user;                       // Giriş yapan kullanıcı (opsiyonel)
  final List<List<int?>>? bloodPressure;      // Önceden alınmış tansiyon verileri
  final List<Map<String, dynamic>>? bloodSugar; // Önceden alınmış şeker ölçümleri

  const ChatbotScreen({
    Key? key,
    this.user,
    this.bloodPressure,
    this.bloodSugar,
  }) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController(); // Mesaj yazma alanı kontrolcüsü
  final List<Map<String, String>> _messages = []; // Sohbet geçmişi (rol: user/bot, text)
  AppUser? _user;                                // Güncel kullanıcı
  List<List<int?>> _bp = List.generate(5, (_) => [null, null]); // Tansiyon kayıtları
  List<Map<String, dynamic>> _sugar = [];        // Şeker kayıtları
  final StorageService _storage = StorageService(); // Firestore’dan veri çekmek için servis

  @override
  void initState() {
    super.initState();
    _initData(); // Başlangıçta verileri çek
  }

  /// Kullanıcı, şeker ve tansiyon verilerini Firestore veya widget parametrelerinden yükler
  Future<void> _initData() async {
    _user = widget.user ?? await _storage.getUserDataFromFirestore();
    final bpFromStorage = widget.bloodPressure ?? await _storage.getBloodPressure();
    final sugarFromStorage = widget.bloodSugar ?? await _storage.getBloodSugarRecords();
    setState(() {
      if (bpFromStorage.isNotEmpty) _bp = bpFromStorage;
      if (sugarFromStorage.isNotEmpty) _sugar = sugarFromStorage;
    });
  }

  /// Mesaj gönderme işlemi
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Kullanıcının mesajını listeye ekle
    setState(() => _messages.add({'role': 'user', 'text': text}));
    _controller.clear();
    _replyTo(text); // Cevap üret
  }

  /// Kullanıcı mesajına basit kurallara göre cevap verir
  void _replyTo(String input) {
    final lower = input.toLowerCase();
    String reply;

    if (lower.contains('şeker')) {
      // Son şeker kaydını göster
      if (_sugar.isNotEmpty) {
        final latest = _sugar.last['value'];
        reply = 'Son şeker ölçümünüz: $latest mg/dL';
      } else {
        reply = 'Henüz şeker kaydı yok.';
      }
    } else if (lower.contains('tansiyon')) {
      // Son tansiyon kaydını göster
      final valid = _bp.where((e) => e[0] != null && e[1] != null).toList();
      if (valid.isNotEmpty) {
        final last = valid.last;
        reply = 'En son tansiyonunuz: ${last[0]}/${last[1]} mmHg.';
      } else {
        reply = 'Henüz tansiyon kaydı yok.';
      }
    } else if (lower.contains('diyabet') || lower.contains('risk')) {
      // Basit diyabet risk değerlendirmesi
      int riskScore = 0;
      if (_sugar.isNotEmpty) {
        final v = _sugar.last['value'];
        if (v is int && v > 125) riskScore += 2;
        else if (v is int && v > 100) riskScore += 1;
      }
      if (_user != null && _user!.age >= 45) riskScore++;
      final highBp = _bp.any((e) => e[0] != null && e[1] != null && (e[0]! > 140 || e[1]! > 90));
      if (highBp) riskScore++;

      if (riskScore >= 3) reply = 'Yüksek diyabet riski. Doktora danışın.';
      else if (riskScore == 2) reply = 'Orta risk. Kontrol önerilir.';
      else reply = 'Düşük risk.';
    } else if (lower.contains('merhaba')) {
      // Basit selamlama
      reply = 'Merhaba${_user != null ? ' ${_user!.name}' : ''}!';
    } else {
      // Varsayılan cevap
      reply = 'Şeker, tansiyon veya diyabet riskiyle ilgili sorular sorabilirsiniz.';
    }

    // Bot cevabını küçük gecikmeyle ekle
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _messages.add({'role': 'bot', 'text': reply}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sağlık ChatBot')),
      body: SafeArea(
        child: Column(
          children: [
            // Sohbet geçmişi
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                child: Text('Merhaba! Sorularınızı yazabilirsiniz.'),
              )
                  : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    final isUser = m['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['text'] ?? ''),
                      ),
                    );
                  }),
            ),
            const Divider(height: 1),
            // Mesaj yazma alanı ve gönderme butonu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
