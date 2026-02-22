/// Uygulamadaki iki kullanıcı tipi.
///
/// - [food]     → Normal kullanıcı. Yemek satın alabilir, Gönüllü modülüne erişebilir.
/// - [business] → İşletme kullanıcısı. Yemek listeleyebilir, Gönüllü modülüne erişebilir.
enum UserType { food, business }

/// Kullanıcı modeli
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserType userType;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });

  bool get isBusiness => userType == UserType.business;
  bool get isFood => userType == UserType.food;

  /// Her iki kullanıcı tipi de Gönüllü modülüne erişebilir.
  bool get canAccessVolunteer => true;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userType: (json['userType'] as String?) == 'business'
          ? UserType.business
          : UserType.food,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'userType': userType.name,
      };
}
