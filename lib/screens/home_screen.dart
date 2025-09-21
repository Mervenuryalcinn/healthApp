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

/// Ana sayfa ve alt menü (bottom navigation) barı içeren temel ekran
class HomeScreen extends StatefulWidget {
  final AppUser user; // Giriş yapan kullanıcı bilgisi
  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // BottomNavigationBar’da seçili sekme
  List<List<int?>> _bloodPressure = []; // Tansiyon kayıtları (günlük sistolik/diastolik)
  List<Map<String, dynamic>> _bloodSugarRecords = []; // Kan şekeri kayıtları
  final StorageService _storageService = StorageService();
  late AppUser _currentUser; // Ekrandaki güncel kullanıcı bilgisi

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // Parametre olarak gelen kullanıcıyı state’e kopyala
    _initializeUserData();      // Firestore ve local storage verilerini çek
  }

  /// Kullanıcı verilerini Firestore'dan ve local storage’dan yükler
  void _initializeUserData() async {
    try {
      // Firestore'dan kullanıcı verisini al
      final AppUser? firestoreUser =
          await _storageService.getUserDataFromFirestore();

      // Firestore’da varsa onu kullan, yoksa girişten gelen user’ı kullan
      final AppUser currentUser = firestoreUser ?? widget.user;

      // StorageService’e kullanıcı ID’sini ilet
      _storageService.setUserId(currentUser.id);

      // Widget hala ekrandaysa state’i güncelle
      if (!mounted) return;
      setState(() {
        _bloodPressure = _storageService.getBloodPressure();
        _bloodSugarRecords = _storageService.getBloodSugarRecords();
        _currentUser = currentUser;
      });
    } catch (e) {
      debugPrint("User data initialize error: $e");
    }
  }

  /// Güncel verileri local storage’a kaydeder
  Future<void> _saveData() async {
    await _storageService.saveBloodPressure(_bloodPressure);
    await _storageService.saveBloodSugarRecords(_bloodSugarRecords);
  }

  /// BottomNavigationBar sekmesi değiştirildiğinde çalışır
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Tansiyon verisi güncellenince çağrılır
  void _updateBloodPressure(List<List<int?>> newBloodPressure) {
    setState(() {
      _bloodPressure = newBloodPressure;
    });
    _saveData();
  }

  /// Kan şekeri verisi güncellenince çağrılır
  void _updateBloodSugarRecords(List<Map<String, dynamic>> newRecords) {
    setState(() {
      _bloodSugarRecords = newRecords;
    });
    _saveData();
  }

  /// Kullanıcıyı sistemden çıkarır
  void _logout() async {
    await AuthService.logout();
    _storageService.setUserId(''); // User ID’yi temizle
    Fluttertoast.showToast(msg: 'Çıkış yapıldı');
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Veri giriş ekranını açar ve sonucu alır
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

    // Kullanıcı veri girişi yaptıysa listeyi güncelle
    if (result != null) {
      if (result['bloodSugar'] != null) {
        setState(() {
          _bloodSugarRecords.add({
            'value': result['bloodSugar'],
            'time': DateTime.now()
          });
        });
        _saveData();
      }
      if (result['bloodPressure'] != null) {
        final bp = result['bloodPressure'];
        setState(() {
          _bloodPressure[bp['day']] = [bp['systolic'], bp['diastolic']];
        });
        _saveData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst bar
      appBar: AppBar(
        title: Text('Sağlık Takip Uygulaması'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildCurrentScreen(), // Alt menüye göre içerik
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
          BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety), label: 'Öneriler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat Bot'),
        ],
      ),
      // Ana sayfada (+) butonu ile ölçüm ekleme
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _openDataInputScreen(context),
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Alt menüde seçilen sekmeye göre ekrana getirilecek widget
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
        return RecommendationsScreen();
      case 3:
        return ProfileScreen(
          user: _currentUser,
          onProfileUpdated: (AppUser updatedUser) {
            // Profil güncellenince hem state hem de storage güncellenir
            setState(() {
              _currentUser = updatedUser;
              _storageService.setUserId(updatedUser.id);
            });
          },
        );
      case 4:
        return ChatbotScreen();
      default:
        return Container();
    }
  }
}

/// Ana sayfa içerik widget'ı
/// Kullanıcının sağlık karnesini, son ölçümleri ve butonları gösterir
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

  /// Yaş gruplarına göre tansiyon sınır değerleri
  final Map<String, List<int>> ageGroups = {
    '14-18': [100, 120, 65, 85],
    '19-39': [110, 130, 70, 85],
    '40-59': [115, 135, 75, 90],
    '60+': [120, 140, 80, 90],
  };

  /// Kullanıcının yaşına uygun grup etiketi
  String getAgeGroup(int age) {
    if (age >= 14 && age <= 18) return '14-18';
    if (age >= 19 && age <= 39) return '19-39';
    if (age >= 40 && age <= 59) return '40-59';
    return '60+';
  }

  /// Ortalama tansiyon değerini yaş grubuna göre analiz eder
  String analyzeBloodPressure(int avgSystolic, int avgDiastolic) {
    String group = getAgeGroup(userAge);
    var range = ageGroups[group]!;
    if (avgSystolic < range[0] || avgDiastolic < range[2]) return 'Düşük';
    if (avgSystolic > range[1] || avgDiastolic > range[3]) return 'Yüksek';
    return 'Normal';
  }

  /// Tüm tansiyon verilerini siler
  void _clearAllBloodPressureData() {
    setState(() {
      for (int i = 0; i < widget.bloodPressure.length; i++) {
        widget.bloodPressure[i] = [null, null];
      }
      widget.onBloodPressureUpdated(widget.bloodPressure);
    });
    Fluttertoast.showToast(msg: 'Tüm tansiyon verileri silindi');
  }

  /// 5 günlük tansiyon takvimini gösterir
  void _showCalendarView(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('5 Günlük Tansiyon Takvimi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                final day = index + 1;
                final systolic = widget.bloodPressure[index][0];
                final diastolic = widget.bloodPressure[index][1];

                return ListTile(
                  title: Text('Gün $day'),
                  subtitle: Text(
                      systolic != null && diastolic != null
                          ? '$systolic/$diastolic mmHg'
                          : 'Henüz ölçüm yapılmadı'
                  ),
                  trailing: systolic != null && diastolic != null
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.cancel, color: Colors.red),
                );
              },
            ),
          ),
          actions: [
            // En az bir veri varsa toplu silme butonu göster
            if (widget.bloodPressure.any((bp) => bp[0] != null && bp[1] != null))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showClearConfirmationDialog(context);
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

  /// Tüm verileri silme onayı
  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Tüm tansiyon verileri silinecek. Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllBloodPressureData();
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
    // Ortalama tansiyon ve son şeker değerlerini hesapla
    int sumSystolic = 0, sumDiastolic = 0, count = 0;
    for (var bp in widget.bloodPressure) {
      if (bp[0] != null && bp[1] != null) {
        sumSystolic += bp[0]!;
        sumDiastolic += bp[1]!;
        count++;
      }
    }

    int avgSystolic = count > 0 ? (sumSystolic / count).round() : 0;
    int avgDiastolic = count > 0 ? (sumDiastolic / count).round() : 0;
    String bpResult = count == 5 ? analyzeBloodPressure(avgSystolic, avgDiastolic) : '';
    int? latestSugar = widget.bloodSugarRecords.isNotEmpty
        ? widget.bloodSugarRecords.last['value']
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoş Geldiniz, ${widget.user.name}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          /// Diyabet tahmini ekranına yönlendirme
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DiabetesPredictionScreen()),
              );
            },
            child: Text('Tip 2 Diyabet Tahmini Yap'),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
          ),
          SizedBox(height: 20),

          /// Sağlık karnesi kartları (Şeker ve Tansiyon)
          Text('Sağlık Karnesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              // Kan şekeri kartı
              Expanded(
                child: HealthCard(
                  title: 'Şeker',
                  value: latestSugar != null ? '$latestSugar mg/dL' : '-',
                  riskLevel: latestSugar != null
                      ? (latestSugar < 70
                          ? 'Düşük'
                          : latestSugar > 130
                              ? 'Yüksek'
                              : 'Normal')
                      : '-',
                  color: latestSugar != null
                      ? (latestSugar < 70
                          ? Colors.orange
                          : latestSugar > 130
                              ? Colors.red
                              : Colors.green)
                      : Colors.grey,
                ),
              ),
              SizedBox(width: 10),

              // Tansiyon kartı (takvim açılır)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCalendarView(context),
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

          /// Son ölçümler listesi
          Text('Son Ölçümler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          if (widget.bloodSugarRecords.isNotEmpty)
            Card(
              child: ListTile(
                leading: Icon(Icons.monitor_heart, color: Colors.green),
                title: Text('Açlık Şekeri'),
                subtitle: Text(
                    '${widget.bloodSugarRecords.last['value']} mg/dL • '
                    '${widget.bloodSugarRecords.last['time'].hour}:'
                    '${widget.bloodSugarRecords.last['time'].minute.toString().padLeft(2, '0')}'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          if (count > 0)
            Card(
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text('Tansiyon'),
                subtitle: Text('$avgSystolic/$avgDiastolic mmHg'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
        ],
      ),
    );
  }
}
