class ProWineModel {
  final String id;
  final String name;
  final String grape;
  final String year;
  final String country;
  final String region;
  final int bottles;
  final String notes;
  final String image;

  ProWineModel({
    required this.id,
    required this.name,
    required this.grape,
    required this.year,
    required this.country,
    required this.region,
    required this.bottles,
    required this.notes,
    required this.image,
  });

  factory ProWineModel.fromJson(Map<String, dynamic> json) {
    return ProWineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      grape: json['grape'] ?? '',
      year: json['year'] ?? '',
      country: json['country'] ?? '',
      region: json['region'] ?? '',
      bottles: json['bottles'] ?? 1,
      notes: json['notes'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grape': grape,
      'year': year,
      'country': country,
      'region': region,
      'bottles': bottles,
      'notes': notes,
      'image': image,
    };
  }

  ProWineModel copyWith({
    String? id,
    String? name,
    String? grape,
    String? year,
    String? country,
    String? region,
    int? bottles,
    String? notes,
    String? image,
  }) {
    return ProWineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      grape: grape ?? this.grape,
      year: year ?? this.year,
      country: country ?? this.country,
      region: region ?? this.region,
      bottles: bottles ?? this.bottles,
      notes: notes ?? this.notes,
      image: image ?? this.image,
    );
  }
}
