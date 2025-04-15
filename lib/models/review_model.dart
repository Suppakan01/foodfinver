import 'package:cloud_firestore/cloud_firestore.dart';

//โมเดลสำหรับเก็บข้อมูลรีวิวร้านอาหาร
class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String userPhotoURL;
  final String comment;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.userPhotoURL,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  //แปลงข้อมูลจาก Firestore เป็นโมเดล
  factory ReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      restaurantId: data['restaurantId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoURL: data['userPhotoURL'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  //แปลงโมเดลเป็นรูปแบบที่เก็บใน Firestore
  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
