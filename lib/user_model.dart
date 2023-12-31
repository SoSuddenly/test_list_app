class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;

  //картинки не зберігаємо ніде. нема інтернету - тільки дані щоб не загаджувати пам'ять.
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatarUrl,
    };
  }
}
