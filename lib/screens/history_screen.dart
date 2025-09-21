import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final List<List<int?>> bloodPressure;
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
        title: Text('Ölçüm Geçmişi'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Şeker Ölçüm Geçmişi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (widget.bloodSugarRecords.isEmpty)
              Text('Henüz şeker ölçümü yapılmamış.')
            else
              Column(
                children: widget.bloodSugarRecords.map((record) => Card(
                  child: ListTile(
                    leading: Icon(Icons.monitor_heart, color: Colors.green),
                    title: Text('Açlık Şekeri'),
                    subtitle: Text(
                        '${record['value']} mg/dL • ${record['time'].day}.${record['time'].month}.${record['time'].year} ${record['time'].hour}:${record['time'].minute}'),
                  ),
                )).toList(),
              ),

            SizedBox(height: 20),
            Text('Tansiyon Ölçüm Geçmişi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (!widget.bloodPressure.any((bp) => bp[0] != null && bp[1] != null))
              Text('Henüz tansiyon ölçümü yapılmamış.')
            else
              Column(
                children: widget.bloodPressure.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bp = entry.value;
                  if (bp[0] != null && bp[1] != null) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.favorite, color: Colors.red),
                        title: Text('Gün ${index + 1} Tansiyon'),
                        subtitle: Text('${bp[0]}/${bp[1]} mmHg'),
                      ),
                    );
                  } else {
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