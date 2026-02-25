class UserModel {
  final String userId;
  final String name;
  final String email;
  final String plan;
  final int? age;
  final String? country;
  final String? gender;
  final String? role;
  final String? avatar;
  final String? token;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.plan,
    this.age,
    this.country,
    this.gender,
    this.role,
    this.avatar,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      plan: json['plan'] ?? 'FREE',
      age: json['age'],
      country: json['country'],
      gender: json['gender'],
      role: json['role'],
      avatar: json['avatar'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'plan': plan,
      'age': age,
      'country': country,
      'gender': gender,
      'role': role,
      'avatar': avatar,
      'token': token,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? plan,
    int? age,
    String? country,
    String? gender,
    String? role,
    String? avatar,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      age: age ?? this.age,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }
}