import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/health_card.dart';
import 'data_input_screen.dart';
import 'recommendations_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'diabetes_prediction_screen.dart';
import '../services/storage_service.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user; // Giriş yapan kullanıcının bilgileri
  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Alt menüde seçili olan index
  List<List<int?>> _bloodPressure = []; // Tansiyon verileri (sistolik/diastolik)
  List<Map<String, dynamic>> _bloodSugarRecords = []; // Kan şekeri kayıtları
  final StorageService _storageService = StorageService(); // Verileri saklamak için servis
  late AppUser _currentUser; // Şu anki kullanıcı bilgisi

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // İlk kullanıcı bilgisi parametreden alınıyor
    _initializeUserData(); // Firestore'dan kullanıcı verileri yükleniyor
  }

  /// Firestore'dan kullanıcı verilerini alıp state'e set eder
  void _initializeUserData() async {
    try {
      // Önce kullanıcı ID’yi set et
      _storageService.setUserId(widget.user.id);

      // Firestore’dan kullanıcı verilerini al
      final AppUser? firestoreUser =
      await _storageService.getUserDataFromFirestore();
      final AppUser currentUser = firestoreUser ?? widget.user;

      if (!mounted) return;
      setState(() {
        _currentUser = currentUser;
        _bloodPressure = List.from(_storageService.getBloodPressure());
        _bloodSugarRecords = List.from(_storageService.getBloodSugarRecords());
      });
    } catch (e) {
      debugPrint("User data initialize error: $e");
    }
  }

  /// Verileri kalıcı olarak kaydeder
  Future<void> _saveData() async {
    if (_currentUser.id.isEmpty) {
      debugPrint("Error: User ID boş, veri kaydedilemiyor");
      return;
    }

    _storageService.setUserId(_currentUser.id); // her zaman güncel ID
    await _storageService.saveBloodPressure(List.from(_bloodPressure));
    await _storageService.saveBloodSugarRecords(List.from(_bloodSugarRecords));
  }

  /// Alt menüde index değiştiğinde çağrılır
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Yeni tansiyon değerleri geldiğinde kaydedilir
  void _updateBloodPressure(List<List<int?>> newBloodPressure) {
    setState(() {
      _bloodPressure = newBloodPressure;
    });
    _saveData();
  }

  /// Yeni kan şekeri kayıtları geldiğinde kaydedilir
  void _updateBloodSugarRecords(List<Map<String, dynamic>> newRecords) {
    setState(() {
      _bloodSugarRecords = newRecords;
    });
    _saveData();
  }

  /// Çıkış işlemi (Firebase + local storage temizleniyor)
  void _logout() async {
    await AuthService.logout();
    _storageService.setUserId('');
    Fluttertoast.showToast(msg: 'Çıkış yapıldı');
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Veri girişi ekranını açar, dönen sonuçları state'e kaydeder
  Future<void> _openDataInputScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DataInputScreen(
          bloodSugar: _bloodSugarRecords.isNotEmpty
              ? _bloodSugarRecords.last['value']
              : null,
          bloodPressure: _bloodPressure,
        ),
      ),
    );

    if (result != null) {
      // Kan şekeri eklendiğinde listeye ekle
      if (result['bloodSugar'] != null) {
        setState(() {
          _bloodSugarRecords = List.from(_bloodSugarRecords)
            ..add({'value': result['bloodSugar'], 'time': DateTime.now()});
        });
        await _saveData(); // Hemen kaydet
        Fluttertoast.showToast(msg: 'Kan şekeri kaydedildi');
      }

      // Tansiyon eklendiğinde listeye ekle
      if (result['bloodPressure'] != null) {
        final bp = result['bloodPressure'];
        setState(() {
          while (_bloodPressure.length <= bp['day']) {
            _bloodPressure.add([null, null]);
          }
          _bloodPressure = List.from(_bloodPressure); // güvenli kopya
          _bloodPressure[bp['day']] = [bp['systolic'], bp['diastolic']];
        });
        await _saveData(); // Hemen kaydet
        Fluttertoast.showToast(msg: 'Tansiyon kaydedildi');
      }
    }
  }

  /// Seçilen ekrana göre body render edilir
  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(
          user: _currentUser,
          bloodPressure: _bloodPressure,
          bloodSugarRecords: _bloodSugarRecords,
          onBloodPressureUpdated: _updateBloodPressure,
          onBloodSugarUpdated: _updateBloodSugarRecords,
          onOpenDataInput: () => _openDataInputScreen(context),
        );
      case 1:
        return HistoryScreen(
          bloodPressure: _bloodPressure,
          bloodSugarRecords: _bloodSugarRecords,
        );
      case 2:
        return ChatbotScreen();
      case 3:
        return RecommendationsScreen();
      case 4:
        return ProfileScreen(
          user: _currentUser,
          onProfileUpdated: (AppUser updatedUser) {
            setState(() {
              _currentUser = updatedUser;
              _storageService.setUserId(updatedUser.id);
            });
          },
        );
      default:
        return HomeContent(
          user: _currentUser,
          bloodPressure: _bloodPressure,
          bloodSugarRecords: _bloodSugarRecords,
          onBloodPressureUpdated: _updateBloodPressure,
          onBloodSugarUpdated: _updateBloodSugarRecords,
          onOpenDataInput: () => _openDataInputScreen(context),
        );
    }
  }

  /// Alt menü (navigasyon çubuğu) tasarımı
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF2D6A4F),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Geçmiş',
            ),
            BottomNavigationBarItem(
              // Chat butonu özel tasarımlı
              icon: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2D6A4F),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_outlined),
              activeIcon: Icon(Icons.health_and_safety),
              label: 'Öneriler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst bar (app bar)
      appBar: AppBar(
        title: Text(
          'Sağlık Takip Uygulaması',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2D6A4F),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Çıkış işlemi
          ),
        ],
      ),

      // Seçilen ekrana göre body render edilir
      body: _buildCurrentScreen(),

      // Alt menü (BottomNavigationBar)
      bottomNavigationBar: _buildBottomNavigationBar(),

      // Ana sayfadayken veri ekleme butonu görünür
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => _openDataInputScreen(context),
        child: Icon(Icons.add, size: 30),
        backgroundColor: Color(0xFF2D6A4F),
        elevation: 5,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class HomeContent extends StatefulWidget {
  final AppUser user;
  final List<List<int?>> bloodPressure;
  final List<Map<String, dynamic>> bloodSugarRecords;
  final Function(List<List<int?>>) onBloodPressureUpdated;
  final Function(List<Map<String, dynamic>>) onBloodSugarUpdated;
  final VoidCallback onOpenDataInput;

  HomeContent({
    required this.user,
    required this.bloodPressure,
    required this.bloodSugarRecords,
    required this.onBloodPressureUpdated,
    required this.onBloodSugarUpdated,
    required this.onOpenDataInput,
  });

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int get userAge => widget.user.age;

  final Map<String, List<int>> ageGroups = {
    '14-18': [100, 120, 65, 85],
    '19-39': [110, 130, 70, 85],
    '40-59': [115, 135, 75, 90],
    '60+': [120, 140, 80, 90],
  };

  String getAgeGroup(int age) {
    if (age >= 14 && age <= 18) return '14-18';
    if (age >= 19 && age <= 39) return '19-39';
    if (age >= 40 && age <= 59) return '40-59';
    return '60+';
  }

  String analyzeBloodPressure(int avgSystolic, int avgDiastolic) {
    String group = getAgeGroup(userAge);
    var range = ageGroups[group]!;
    if (avgSystolic < range[0] || avgDiastolic < range[2]) return 'Düşük';
    if (avgSystolic > range[1] || avgDiastolic > range[3]) return 'Yüksek';
    return 'Normal';
  }

  // Tüm şeker verilerini temizleyen fonksiyon
  void _clearAllBloodSugarData() {
    setState(() {
      widget.bloodSugarRecords.clear();
      widget.onBloodSugarUpdated(widget.bloodSugarRecords);
    });
    Fluttertoast.showToast(msg: 'Tüm şeker verileri silindi');
  }

  // Şeker geçmişini gösteren dialog
  void _showSugarHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Kan Şekeri Geçmişi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: widget.bloodSugarRecords.isEmpty
                ? Center(child: Text('Henüz ölçüm yapılmadı'))
                : ListView.builder(
              itemCount: widget.bloodSugarRecords.length,
              itemBuilder: (context, index) {
                final record = widget.bloodSugarRecords[index];
                final value = record['value'];
                final time = record['time'] as DateTime;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text('$value mg/dL'),
                    subtitle: Text(
                        '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}'
                    ),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ),
          actions: [
            if (widget.bloodSugarRecords.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showClearSugarConfirmationDialog(context);
                },
                child: Text('Tümünü Sil', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Şeker silme onay dialogu
  void _showClearSugarConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Tüm kan şekeri verileri silinecek. Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllBloodSugarData();
              },
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Tüm tansiyon verilerini temizleyen fonksiyon
  void _clearAllBloodPressureData() {
    setState(() {
      // Tüm günleri null yaparak temizle
      for (int i = 0; i < widget.bloodPressure.length; i++) {
        widget.bloodPressure[i] = [null, null];
      }
      // Ana widget'a temizlenmiş verileri bildir
      widget.onBloodPressureUpdated(widget.bloodPressure);
    });
    // Kullanıcıya işlem sonucu mesaj göster
    Fluttertoast.showToast(msg: 'Tüm tansiyon verileri silindi');
  }

  // Tansiyon takvimini gösteren dialog fonksiyonu
  void _showCalendarView(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Dialog başlığı
          title: Text(
            '5 Günlük Tansiyon Takvimi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // 5 günlük ölçümleri listeleyen içerik
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // 5 günlük ölçüm
              itemBuilder: (context, index) {
                final day = index + 1;
                final systolic = widget.bloodPressure[index][0];
                final diastolic = widget.bloodPressure[index][1];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text('Gün $day',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    // Ölçüm mevcutsa göster, yoksa bilgilendirici mesaj göster
                    subtitle: Text(
                      systolic != null && diastolic != null
                          ? '$systolic/$diastolic mmHg'
                          : 'Henüz ölçüm yapılmadı',
                    ),
                    // Ölçüm yapılmışsa yeşil onay, yoksa gri iptal ikonu
                    trailing: systolic != null && diastolic != null
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // Dialog altındaki aksiyon butonları
          actions: [
            // Eğer ölçüm varsa tümünü silme seçeneği
            if (widget.bloodPressure.any((bp) =>
            bp[0] != null && bp[1] != null))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Önce dialogu kapat
                  _showClearConfirmationDialog(
                      context); // Silme onay dialogunu göster
                },
                child: Text('Tümünü Sil', style: TextStyle(color: Colors.red)),
              ),
            // Dialogu kapatma butonu
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Tüm tansiyon verilerini silmeden önce kullanıcıdan onay almak için gösterilen dialog
  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Dialog başlığı
          title: Text('Emin misiniz?'),
          // Dialog açıklama metni
          content: Text(
              'Tüm tansiyon verileri silinecek. Bu işlem geri alınamaz.'),
          // Dialogdaki aksiyon butonları
          actions: [
            // İptal butonu: dialogu kapatır ve hiçbir işlem yapmaz
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            // Sil butonu: dialogu kapatır ve tüm tansiyon verilerini temizleme fonksiyonunu çağırır
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
                _clearAllBloodPressureData(); // Tüm tansiyon verilerini temizle
              },
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tansiyon verilerini toplamak ve ortalamalarını hesaplamak için değişkenler
    int sumSystolic = 0,
        sumDiastolic = 0,
        count = 0;

    // widget.bloodPressure listesindeki tüm ölçümleri dolaş
    for (var bp in widget.bloodPressure) {
      if (bp[0] != null && bp[1] != null) {
        sumSystolic += bp[0]!; // Sistolik değerleri toplar
        sumDiastolic += bp[1]!; // Diyastolik değerleri toplar
        count++; // Geçerli ölçüm sayısını artırır
      }
    }

    // Ortalama tansiyon değerlerini hesapla, eğer ölçüm yoksa 0 ata
    int avgSystolic = count > 0 ? (sumSystolic / count).round() : 0;
    int avgDiastolic = count > 0 ? (sumDiastolic / count).round() : 0;

    // Ortalama tansiyon sonucu sadece 5 ölçüm varsa analiz edilir
    String bpResult = count == 5 ? analyzeBloodPressure(
        avgSystolic, avgDiastolic) : '';

    // Son ölçülen kan şekeri değeri, eğer kayıt yoksa null
    int? latestSugar = widget.bloodSugarRecords.isNotEmpty ? widget
        .bloodSugarRecords.last['value'] : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcıya hoş geldin mesajı ve profil avatarı
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2D6A4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Kullanıcının isminin baş harfi ile avatar
                CircleAvatar(
                  backgroundColor: Color(0xFF2D6A4F),
                  child: Text(
                    widget.user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                // Kullanıcı adı ve bilgilendirici alt metin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş Geldiniz, ${widget.user.name}!',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D6A4F)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sağlığınızı takip etmek için buradayız',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Diyabet tahmin ekranına geçiş yapan kart
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DiabetesPredictionScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Color(0xFF2D6A4F), size: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tip 2 Diyabet Tahmini',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Risk seviyenizi öğrenin',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Sağlık karnesi başlığı
          Text(
            'Sağlık Karnesi',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F)),
          ),
          SizedBox(height: 10),
          // Şeker ve tansiyon kartlarını yan yana göster
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSugarHistoryDialog(context),
                  child: HealthCard(
                    title: 'Şeker',
                    value: latestSugar != null ? '$latestSugar mg/dL' : '-',
                    // Kan şekeri risk seviyesini belirle
                    riskLevel: latestSugar != null
                        ? (latestSugar < 70
                        ? 'Düşük'
                        : latestSugar > 130
                        ? 'Yüksek'
                        : 'Normal')
                        : '-',
                    // Kartın rengini risk seviyesine göre ayarla
                    color: latestSugar != null
                        ? (latestSugar < 70
                        ? Colors.orange
                        : latestSugar > 130
                        ? Colors.red
                        : Colors.green)
                        : Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCalendarView(context),
                  // Tansiyon takvimini aç
                  child: HealthCard(
                    title: 'Tansiyon',
                    value: count > 0 ? '$avgSystolic/$avgDiastolic' : '-/-',
                    riskLevel: count == 5 ? bpResult : 'Takvim',
                    color: count == 5
                        ? (bpResult == 'Normal'
                        ? Colors.green
                        : bpResult == 'Yüksek'
                        ? Colors.red
                        : Colors.orange)
                        : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Son ölçümler başlığı
          Text(
            'Son Ölçümler',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F)),
          ),
          SizedBox(height: 10),
          // Son kan şekeri ölçümü kartı
          if (widget.bloodSugarRecords.isNotEmpty)
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D6A4F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.monitor_heart, color: Color(0xFF2D6A4F)),
                ),
                title: Text('Açlık Şekeri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${widget.bloodSugarRecords.last['value']} mg/dL • ${widget
                      .bloodSugarRecords.last['time'].hour}:${widget
                      .bloodSugarRecords.last['time'].minute.toString().padLeft(
                      2, '0')}',
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
          // Son tansiyon ölçümü kartı
          if (count > 0)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: Colors.red),
                ),
                title: Text(
                    'Tansiyon', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('$avgSystolic/$avgDiastolic mmHg'),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}