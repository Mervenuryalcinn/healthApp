import 'package:flutter/material.dart';

/// Kullanıcının şeker ve tansiyon ölçüm geçmişlerini listeleyen ekran
class HistoryScreen extends StatefulWidget {
  /// Tansiyon ölçümleri (günlük sistolik/diastolik değerler)
  /// Her eleman: [sistolik, diastolik] veya [null, null]
  final List<List<int?>> bloodPressure;

  /// Kan şekeri ölçümleri
  /// Her kayıt: {'value': int, 'time': DateTime}
  final List<Map<String, dynamic>> bloodSugarRecords;

  HistoryScreen({
    required this.bloodPressure,
    required this.bloodSugarRecords,
  });

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Uygulamanın üst başlığı
        title: Text('Ölçüm Geçmişi'),
      ),
      body: SingleChildScrollView(
        // Tüm içeriğin kaydırılabilir olmasını sağlar
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- ŞEKER GEÇMİŞİ BÖLÜMÜ ---
            Text(
              'Şeker Ölçüm Geçmişi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Eğer kayıt yoksa bilgilendirici metin göster
            if (widget.bloodSugarRecords.isEmpty)
              Text('Henüz şeker ölçümü yapılmamış.')
            else
              // Her kan şekeri kaydı için kart listesi
              Column(
                children: widget.bloodSugarRecords.map((record) => Card(
                  child: ListTile(
                    leading: Icon(Icons.monitor_heart, color: Colors.green),
                    title: Text('Açlık Şekeri'),
                    subtitle: Text(
                      // Ölçüm değeri ve ölçüm zamanı
                      '${record['value']} mg/dL • '
                      '${record['time'].day}.${record['time'].month}.${record['time'].year} '
                      '${record['time'].hour}:${record['time'].minute}',
                    ),
                  ),
                )).toList(),
              ),

            SizedBox(height: 20),

            /// --- TANSİYON GEÇMİŞİ BÖLÜMÜ ---
            Text(
              'Tansiyon Ölçüm Geçmişi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Eğer hiç dolu tansiyon kaydı yoksa bilgilendirici metin göster
            if (!widget.bloodPressure.any((bp) => bp[0] != null && bp[1] != null))
              Text('Henüz tansiyon ölçümü yapılmamış.')
            else
              // Her gün için sistolik/diastolik değerlerini listele
              Column(
                children: widget.bloodPressure.asMap().entries.map((entry) {
                  final index = entry.key;   // Gün numarası
                  final bp = entry.value;    // [sistolik, diastolik]

                  // Null olmayan değerler varsa kart oluştur
                  if (bp[0] != null && bp[1] != null) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.favorite, color: Colors.red),
                        title: Text('Gün ${index + 1} Tansiyon'),
                        subtitle: Text('${bp[0]}/${bp[1]} mmHg'),
                      ),
                    );
                  } else {
                    // Ölçüm olmayan günleri gizle
                    return SizedBox.shrink();
                  }
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
