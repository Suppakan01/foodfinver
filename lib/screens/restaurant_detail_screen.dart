import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

import 'review_screen.dart'; // แก้ path ตามโครงสร้างโปรเจคของคุณ

//หน้าจอแสดงรายละเอียดร้านอาหาร
class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailScreen({required this.restaurantId});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late RestaurantModel? _restaurant;
  late List<ReviewModel> _reviews;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  //โหลดข้อมูลร้านอาหารและรีวิว
  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoading = true;
    });

    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    try {
      //ดึงข้อมูลร้านอาหาร
      _restaurant = await restaurantProvider.getRestaurantById(
        widget.restaurantId,
      );

      //ดึงข้อมูลรีวิวของร้านอาหาร
      if (_restaurant != null) {
        // แก้ไขจาก getReviewsByRestaurantId เป็น getRestaurantReviews
        _reviews = await restaurantProvider.getRestaurantReviews(
          widget.restaurantId,
        );
      } else {
        _reviews = [];
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
      _restaurant = null;
      _reviews = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _restaurant == null
              ? Center(child: Text('ไม่พบข้อมูลร้านอาหาร'))
              : CustomScrollView(
                slivers: [
                  //App Bar พร้อมรูปร้านอาหาร
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        _restaurant!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      //ปุ่มเพิ่มลงรายการโปรด
                      IconButton(
                        icon: Icon(
                          authProvider.isFavorite(_restaurant!.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              authProvider.isFavorite(_restaurant!.id)
                                  ? Colors.red
                                  : Colors.white,
                        ),
                        onPressed: () {
                          if (authProvider.isLoggedIn) {
                            authProvider.toggleFavorite(_restaurant!.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'กรุณาเข้าสู่ระบบเพื่อเพิ่มร้านโปรด',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  //เนื้อหาข้อมูลร้านอาหาร
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //ชื่อร้านและคะแนน
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _restaurant!.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _restaurant!.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          //หมวดหมู่
                          Wrap(
                            spacing: 8,
                            children:
                                _restaurant!.categories.map((category) {
                                  return Chip(
                                    label: Text(category),
                                    backgroundColor: Colors.grey[200],
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(height: 15),

                          //ที่อยู่
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _restaurant!.address,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          // ลบ/ปรับส่วนของเบอร์โทร, เวลาเปิด-ปิด, และเมนูแนะนำ เนื่องจากไม่มีใน model
                          SizedBox(height: 25),

                          //รายละเอียดร้าน
                          Text(
                            'รายละเอียด',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _restaurant!.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 25),

                          //ส่วนหัวของรีวิว
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รีวิวจากผู้ใช้ (${_reviews.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //ปุ่มเพิ่มรีวิว
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (authProvider.isLoggedIn) {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => AddReviewScreen(
                                                  restaurantId:
                                                      widget.restaurantId,
                                                ),
                                          ),
                                        )
                                        .then((_) => _loadRestaurantData());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'กรุณาเข้าสู่ระบบเพื่อเขียนรีวิว',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.rate_review, size: 18),
                                label: Text('เขียนรีวิว'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  //แสดงรายการรีวิว
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (_reviews.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'ยังไม่มีรีวิว กรุณาเป็นคนแรกที่รีวิวร้านนี้',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }

                      final review = _reviews[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //ส่วนหัวรีวิว (ชื่อผู้ใช้และคะแนน)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey[300],
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        review.userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              //เนื้อหารีวิว
                              Text(
                                review.comment,
                                style: TextStyle(fontSize: 15, height: 1.4),
                              ),
                              SizedBox(height: 8),

                              //วันที่รีวิว
                              Text(
                                'รีวิวเมื่อ ${_formatDate(review.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: _reviews.isEmpty ? 1 : _reviews.length),
                  ),

                  //พื้นที่ว่างด้านล่างรายการ
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
    );
  }

  //ฟอร์แมตวันที่ให้เป็นรูปแบบ วัน/เดือน/ปี
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
