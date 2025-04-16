import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

//จัดการข้อมูลร้านอาหารและการค้นหา
class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //ตัวแปรสำหรับเก็บสถานะการโหลดข้อมูล
  bool _isLoading = false;

  //ตัวแปรสำหรับเก็บข้อมูลร้านอาหารทั้งหมด
  List<RestaurantModel> _restaurants = [];

  //ตัวแปรสำหรับเก็บผลการค้นหา
  List<RestaurantModel> _searchResults = [];

  //Getter สำหรับตรวจสอบสถานะการโหลดข้อมูล
  bool get isLoading => _isLoading;

  //Getter สำหรับเรียกดูข้อมูลร้านอาหารทั้งหมด
  List<RestaurantModel> get restaurants => _restaurants;

  //Getter สำหรับเรียกดูผลการค้นหา
  List<RestaurantModel> get searchResults => _searchResults;

  //ดึงข้อมูลร้านอาหารทั้งหมดจาก Firestore
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('restaurants').get();

      _restaurants =
          snapshot.docs.map((doc) {
            return RestaurantModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลร้านอาหาร: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //ค้นหาร้านอาหารตามชื่อ
  void searchRestaurants(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults =
          _restaurants.where((restaurant) {
            return restaurant.name.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                restaurant.categories.any(
                  (category) =>
                      category.toLowerCase().contains(query.toLowerCase()),
                );
          }).toList();
    }

    notifyListeners();
  }

  //ดึงข้อมูลร้านอาหารตาม ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      //ตรวจสอบใน cache ก่อน
      RestaurantModel? restaurant = _restaurants.firstWhere(
        (r) => r.id == id,
        orElse:
            () => RestaurantModel(
              id: '',
              name: '',
              description: '',
              imageUrl: '',
              address: '',
              rating: 0,
              categories: [],
              location: {'latitude': 0.0, 'longitude': 0.0},
            ),
      );

      //ถ้าไม่พบในแคช ดึงข้อมูลจาก Firestore
      if (restaurant.id.isEmpty) {
        DocumentSnapshot doc =
            await _firestore.collection('restaurants').doc(id).get();

        if (doc.exists) {
          return RestaurantModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }
      } else {
        return restaurant;
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลร้านอาหาร: $e');
    }

    return null;
  }

  Future<List<RestaurantModel>> getRestaurantsByIds(List<String> ids) async {
    List<RestaurantModel> results = [];

    try {
      for (String id in ids) {
        RestaurantModel? restaurant = await getRestaurantById(id);
        if (restaurant != null) {
          results.add(restaurant);
        }
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลร้านอาหารจาก IDs: $e');
    }

    return results;
  }

  //ดึงรีวิวทั้งหมดของร้านอาหาร
  Future<List<ReviewModel>> getRestaurantReviews(String restaurantId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('reviews')
              .where('restaurantId', isEqualTo: restaurantId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลรีวิว: $e');
      return [];
    }
  }

  //เพิ่มรีวิวร้านอาหาร
  Future<bool> addReview(ReviewModel review) async {
    try {
      //เพิ่มรีวิวลงใน Firestore
      await _firestore.collection('reviews').add(review.toMap());

      //คำนวณคะแนนเฉลี่ยใหม่
      List<ReviewModel> reviews = await getRestaurantReviews(
        review.restaurantId,
      );
      double avgRating = 0;

      if (reviews.isNotEmpty) {
        double sum = reviews.fold(0, (prev, item) => prev + item.rating);
        avgRating = sum / reviews.length;
      }

      //อัปเดตคะแนนร้านอาหาร
      await _firestore
          .collection('restaurants')
          .doc(review.restaurantId)
          .update({'rating': avgRating});

      //อัปเดตข้อมูลในแคช
      int index = _restaurants.indexWhere((r) => r.id == review.restaurantId);
      if (index != -1) {
        RestaurantModel updatedRestaurant = RestaurantModel(
          id: _restaurants[index].id,
          name: _restaurants[index].name,
          description: _restaurants[index].description,
          imageUrl: _restaurants[index].imageUrl,
          address: _restaurants[index].address,
          rating: avgRating,
          categories: _restaurants[index].categories,
          location: _restaurants[index].location,
        );

        _restaurants[index] = updatedRestaurant;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเพิ่มรีวิว: $e');
      return false;
    }
  }
}
