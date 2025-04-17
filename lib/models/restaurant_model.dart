class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final double rating;
  final List<String> categories;
  final Map<String, dynamic> location;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.categories,
    required this.location,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> data, String id) {
    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      rating: _parseToDouble(data['rating']),
      categories: List<String>.from(data['categories'] ?? []),
      location: data['location'] ?? {'latitude': 0.0, 'longitude': 0.0},
    );
  }

  //สำหรับJSON restaurant.json
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['URL'] ?? '', // ใช้ URL เป็น id แทน
      name: json['Name'] ?? '',
      description: json['Detail'] ?? '',
      imageUrl: json['IntroImage'] ?? '',
      address: '${json['District'] ?? ''}, ${json['Province'] ?? ''}',
      rating: json['IsOpen'] == 1 ? 4.5 : 3.5, // สมมุติคะแนนเบื้องต้น
      categories: [json['Region'] ?? ''], // ใช้ Region เป็นหมวดหมู่คร่าว ๆ
      location: {
        'latitude': json['Latitude'] ?? 0.0,
        'longitude': json['Longitude'] ?? 0.0,
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'rating': rating,
      'categories': categories,
      'location': location,
    };
  }
}

//ฟังก์ชันแปลงค่าให้เป็น double อย่างปลอดภัย
double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
