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
    final dynamic rawRole = json['userType'] ?? json['user_type'] ?? json['userRole'] ?? json['user_role'];
    final role = (rawRole?.toString().toLowerCase() ?? 'food');
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userType: role == 'business' ? UserType.business : UserType.food,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'userType': userType.name,
      };
}
