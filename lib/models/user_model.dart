class User {
  final String email;
  final String password;
  final String boxId;
  final String? phone;

  User({
    required this.email,
    required this.password,
    required this.boxId,
    this.phone,
  });

  // Converte um User em um Map (necessário para o sqflite)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'boxId': boxId,
      'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      password: map['password'] as String,
      boxId: map['boxId'] as String,
      phone: map['phone'] as String?, // Pode ser String ou null
    );
  }
}
