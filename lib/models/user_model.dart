import 'package:cloud_firestore/cloud_firestore.dart';

//โมเดลสำหรับเก็บข้อมูลผู้ใช้
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String password;
  String? photoURL;
  final int? reviewCount;
  final DateTime? createdAt;
  List<String> favorites;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber = '',
    this.password = '',
    this.photoURL,
    this.reviewCount = 0,
    this.createdAt,
    required this.favorites,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: '',
      photoURL: map['photoURL'],
      reviewCount: map['reviewCount'] ?? 0,
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  //แปลงโมเดลเป็นรูปแบบที่เก็บใน Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'favorites': favorites,
    };
  }

  //เมธอดสำหรับสร้าง UserModel ใหม่ที่มีข้อมูลบางส่วนเปลี่ยนไป
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? password,
    String? photoURL,
    int? reviewCount,
    DateTime? createdAt,
    List<String>? favorites,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      photoURL: photoURL ?? this.photoURL,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      favorites: favorites ?? this.favorites,
    );
  }
}
