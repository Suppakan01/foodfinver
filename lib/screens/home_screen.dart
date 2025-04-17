import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant_model.dart';
import 'restaurant_detail_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

//หน้าจอหลักแสดงรายการร้านอาหาร
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );
      await restaurantProvider.loadRestaurantsFromJson();
    });
  }

  //แสดงหน้าจอตาม tab ที่เลือก
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return SearchScreen();
      case 2:
        return ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  //สร้างเนื้อหาหน้าหลัก
  Widget _buildHomeContent() {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (restaurantProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //ส่วนหัวของหน้าหลัก
          Text(
            'สวัสดี, ยินดีต้อนรับสู่ FoodFinver!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          //ส่วนแสดงร้านแนะนำ
          _buildSectionTitle('ร้านแนะนำ'),
          SizedBox(height: 10),
          _buildFeaturedRestaurants(restaurantProvider.restaurants),
          SizedBox(height: 25),

          //ส่วนแสดงร้านที่มีคะแนนสูง
          _buildSectionTitle('ร้านยอดนิยม'),
          SizedBox(height: 10),
          _buildTopRatedRestaurants(restaurantProvider.restaurants),
          SizedBox(height: 25),

          //ส่วนแสดงร้านทั้งหมด
          _buildSectionTitle('ร้านอาหารทั้งหมด'),
          SizedBox(height: 10),
          _buildAllRestaurants(restaurantProvider.restaurants),
        ],
      ),
    );
  }

  //สร้าง widget หัวข้อสำหรับแต่ละส่วน
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            //ไปที่หน้าค้นหาเมื่อกดดูทั้งหมด
            setState(() {
              _currentIndex = 1;
            });
          },
          child: Text('ดูทั้งหมด'),
        ),
      ],
    );
  }

  //สร้าง widget แสดงร้านแนะนำแบบสไลด์
  Widget _buildFeaturedRestaurants(List<RestaurantModel> restaurants) {
    //สุ่มเลือกร้านอาหาร 5 ร้านจากทั้งหมด (หรือน้อยกว่าถ้ามีไม่ถึง)
    final featuredList = List.from(restaurants);
    featuredList.shuffle();
    final displayList =
        featuredList.length <= 5 ? featuredList : featuredList.sublist(0, 5);

    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          return _buildFeaturedRestaurantItem(displayList[index]);
        },
      ),
    );
  }

  //สร้างแต่ละรายการในส่วนร้านแนะนำ
  Widget _buildFeaturedRestaurantItem(RestaurantModel restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: 15),
        child: Stack(
          children: [
            //รูปร้านอาหาร
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                restaurant.imageUrl,
                width: 280,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 280,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
            ),
            //แถบด้านล่างสำหรับแสดงข้อมูลร้าน
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //สร้าง widget แสดงร้านยอดนิยม (คะแนนสูง)
  Widget _buildTopRatedRestaurants(List<RestaurantModel> restaurants) {
    //เรียงร้านตามคะแนนจากมากไปน้อย
    final topRated = List.from(restaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    //เลือกเฉพาะร้านที่มีคะแนนสูงสุด 5 ร้าน (หรือน้อยกว่าถ้ามีไม่ถึง)
    final displayList =
        topRated.length <= 5 ? topRated : topRated.sublist(0, 5);

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          return _buildTopRatedRestaurantItem(displayList[index]);
        },
      ),
    );
  }

  //สร้างแต่ละรายการในส่วนร้านยอดนิยม
  Widget _buildTopRatedRestaurantItem(RestaurantModel restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            //รูปร้านอาหาร
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                restaurant.imageUrl,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
            ),
            //ข้อมูลร้าน
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      restaurant.categories.join(', '),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //สร้าง widget แสดงร้านอาหารทั้งหมด
  Widget _buildAllRestaurants(List<RestaurantModel> restaurants) {
    if (restaurants.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลร้านอาหาร'));
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount:
          restaurants.length > 6
              ? 6
              : restaurants.length, // แสดงเพียง 6 ร้านในหน้าหลัก
      itemBuilder: (context, index) {
        return _buildRestaurantListItem(restaurants[index]);
      },
    );
  }

  //สร้างแต่ละรายการในส่วนร้านอาหารทั้งหมด
  Widget _buildRestaurantListItem(RestaurantModel restaurant) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            //รูปร้านอาหาร
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ),
                //ปุ่มเพิ่มลงรายการโปรด
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        authProvider.isFavorite(restaurant.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            authProvider.isFavorite(restaurant.id)
                                ? Colors.red
                                : Colors.grey,
                      ),
                      onPressed: () {
                        if (authProvider.isLoggedIn) {
                          authProvider.toggleFavorite(restaurant.id);
                        } else {
                          //ถ้ายังไม่ได้ล็อกอิน แสดงป๊อปอัพให้ล็อกอินก่อน
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text('ต้องเข้าสู่ระบบก่อน'),
                                  content: Text(
                                    'กรุณาเข้าสู่ระบบเพื่อเพิ่มร้านอาหารลงในรายการโปรด',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('ยกเลิก'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('เข้าสู่ระบบ'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => LoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            //ข้อมูลร้าน
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    restaurant.categories.join(', '),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FoodFinver',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              //แสดงป๊อปอัพยืนยันการออกจากระบบ
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('ออกจากระบบ'),
                      content: Text('คุณต้องการออกจากระบบหรือไม่?'),
                      actions: [
                        TextButton(
                          child: Text('ยกเลิก'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: Text('ออกจากระบบ'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            authProvider.logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ค้นหา'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
