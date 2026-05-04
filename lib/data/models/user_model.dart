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
  final String? photo;
  final String? phone;
  final String? cpf;
  final String? address;
  final String? dob;
  final bool? emailVerified; // ✅ Added this field

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
    this.photo,
    this.phone,
    this.cpf,
    this.address,
    this.dob,
    this.emailVerified, // ✅ Added to constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      plan: json['plan'] ?? 'FREE',
      // ✅ Safer age parsing (handles both int and string)
      age: json['age'] is int 
          ? json['age'] 
          : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      country: json['country'],
      gender: json['gender'],
      role: json['role'],
      avatar: json['avatar'],
      token: json['token'],
      photo: json['photo'],
      phone: json['phone'],
      cpf: json['cpf'],
      address: json['address'],
      dob: json['dob'],
      emailVerified: json['emailVerified'], // ✅ Added fromJson
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
      'photo': photo,
      'phone': phone,
      'cpf': cpf,
      'address': address,
      'dob': dob,
      'emailVerified': emailVerified, // ✅ Added toJson
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
    String? photo,
    String? phone,
    String? cpf,
    String? address,
    String? dob,
    bool? emailVerified, // ✅ Added copyWith
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
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      emailVerified: emailVerified ?? this.emailVerified, // ✅ Added copyWith
    );
  }
}