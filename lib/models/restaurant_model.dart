//โมเดลสำหรับเก็บข้อมูลร้านอาหาร
class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final double rating;
  final List<String> categories;
  final Map<String, dynamic> location; //ละติจูด,ลองจิจูด

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

  //แปลงข้อมูลจาก Firestore เป็นโมเดล
  factory RestaurantModel.fromMap(Map<String, dynamic> data, String id) {
    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      categories: List<String>.from(data['categories'] ?? []),
      location: data['location'] ?? {'latitude': 0.0, 'longitude': 0.0},
    );
  }

  //แปลงโมเดลเป็นรูปแบบที่เก็บใน Firestore
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
