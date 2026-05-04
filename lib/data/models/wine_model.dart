class WineModel {
  final String id;
  final String name;
  final String grape;
  final String year;
  final String country;
  final String region;
  final String wineType;
  final int bottles;
  final String notes;
  final String image;
  final String? alcohol;
  final String? volume;

  WineModel({
    required this.id,
    required this.name,
    required this.grape,
    required this.year,
    required this.country,
    required this.region,
    required this.wineType,
    required this.bottles,
    required this.notes,
    required this.image,
    this.alcohol,
    this.volume,
  });

  factory WineModel.fromJson(Map<String, dynamic> json) {
    return WineModel(
      id: json['id'] ?? json['wine_id'] ?? '',
      name: json['name'] ?? json['wine_name'] ?? '',
      grape: json['grape'] ?? '',
      year: json['year']?.toString() ?? json['vintage_year']?.toString() ?? '',
      country: json['country'] ?? '',
      region: json['region'] ?? '',
      wineType: json['wineType'] ?? json['wine_type'] ?? '',
      bottles: json['bottles'] ?? 1,
      notes: json['notes'] ?? '',
      image: json['image'] ?? '',
      alcohol: json['alcohol_percent']?.toString(),
      volume: json['volume_ml']?.toString(),
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
      'wineType': wineType,
      'bottles': bottles,
      'notes': notes,
      'image': image,
      'alcohol_percent': alcohol,
      'volume_ml': volume,
    };
  }

  WineModel copyWith({
    String? id,
    String? name,
    String? grape,
    String? year,
    String? country,
    String? region,
    String? wineType,
    int? bottles,
    String? notes,
    String? image,
    String? alcohol,
    String? volume,
  }) {
    return WineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      grape: grape ?? this.grape,
      year: year ?? this.year,
      country: country ?? this.country,
      region: region ?? this.region,
      wineType: wineType ?? this.wineType,
      bottles: bottles ?? this.bottles,
      notes: notes ?? this.notes,
      image: image ?? this.image,
      alcohol: alcohol ?? this.alcohol,
      volume: volume ?? this.volume,
    );
  }
}

enum WineType {
  red,
  white,
  rose,
  sparkling;

  String getLabel(bool isPT) {
    switch (this) {
      case WineType.red:
        return isPT ? 'Tinto' : 'Red';
      case WineType.white:
        return isPT ? 'Branco' : 'White';
      case WineType.rose:
        return 'Rosé';
      case WineType.sparkling:
        return isPT ? 'Espumante' : 'Sparkling';
    }
  }

  static WineType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'red':
        return WineType.red;
      case 'white':
        return WineType.white;
      case 'rose':
        return WineType.rose;
      case 'sparkling':
        return WineType.sparkling;
      default:
        return WineType.red;
    }
  }
}