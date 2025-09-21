class AppUser {
  final String id;
  final String name;
  final String email;
  final int age;

  AppUser({required this.id, required this.name, required this.email, required this.age});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
    };
  }

  // Firestore'dan veri almak için factory method
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
    );
  }

  // Firestore'a veri göndermek için method
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'age': age,
    };
  }
}