/// 🔹 AppUser Modeli
/// - Kullanıcı bilgilerini temsil eder
/// - Firebase ve local storage ile uyumlu
class AppUser {
  /// 🔹 Kullanıcı ID (Firebase UID veya local ID)
  final String id;
  /// 🔹 Kullanıcı adı
  final String name;
  /// 🔹 Kullanıcı e-posta adresi
  final String email;
  /// 🔹 Kullanıcı yaşı
  final int age;
  /// 🔹 Constructor
  AppUser({required this.id, required this.name, required this.email, required this.age});
  /// 🔹 JSON'dan AppUser oluşturma
  /// - Local storage veya API yanıtlarını parse etmek için kullanılır
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
    );
  }
  /// 🔹 AppUser'i JSON'a dönüştürme
  /// - Local storage veya API gönderimleri için
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
    };
  }
  /// 🔹 Firestore'dan AppUser oluşturma
  /// - Firebase'den gelen verileri parse etmek için kullanılır
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
    );
  }
  /// 🔹 Firestore'a veri gönderme
  /// - UID dışında diğer alanlar gönderilir
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'age': age,
    };
  }
}
