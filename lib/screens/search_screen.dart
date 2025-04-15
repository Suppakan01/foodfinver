import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
import '../models/restaurant_model.dart';
import 'restaurant_detail_screen.dart';

//หน้าจอสำหรับค้นหาร้านอาหาร
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';
  List<String> _categories = ['ทั้งหมด'];

  @override
  void initState() {
    super.initState();
    //โหลดข้อมูลร้านอาหารและหมวดหมู่
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );

      if (restaurantProvider.restaurants.isEmpty) {
        restaurantProvider.fetchRestaurants();
      }

      //ดึงรายการหมวดหมู่ทั้งหมดจากข้อมูลร้านอาหาร
      final allCategories = restaurantProvider.getAllCategories();
      setState(() {
        _categories = ['ทั้งหมด', ...allCategories];
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //ฟังก์ชันกรองร้านอาหารตามคำค้นหาและหมวดหมู่
  List<RestaurantModel> _filterRestaurants(List<RestaurantModel> restaurants) {
    final searchQuery = _searchController.text.toLowerCase();

    return restaurants.where((restaurant) {
      //กรองตามคำค้นหา (ชื่อร้านหรือที่อยู่)
      final matchesSearch =
          searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(searchQuery) ||
          restaurant.address.toLowerCase().contains(searchQuery);

      //กรองตามหมวดหมู่
      final matchesCategory =
          _selectedCategory == 'ทั้งหมด' ||
          restaurant.categories.contains(_selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final filteredRestaurants = _filterRestaurants(
      restaurantProvider.restaurants,
    );

    return Scaffold(
      body: Column(
        children: [
          //ส่วนค้นหา
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                //ช่องค้นหา
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาร้านอาหาร...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    //อัพเดทรายการร้านอาหารเมื่อคำค้นหาเปลี่ยน
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),

                //ตัวเลือกหมวดหมู่
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          //แสดงผลลัพธ์การค้นหา
          Expanded(
            child:
                restaurantProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredRestaurants.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 70,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'ไม่พบร้านอาหารที่ค้นหา',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        return _buildRestaurantItem(filteredRestaurants[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  //สร้างรายการร้านอาหารสำหรับแสดงผลลัพธ์การค้นหา
  Widget _buildRestaurantItem(RestaurantModel restaurant) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            //รูปร้านอาหาร
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                restaurant.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
            ),

            //ข้อมูลร้านอาหาร
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            authProvider.isFavorite(restaurant.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                authProvider.isFavorite(restaurant.id)
                                    ? Colors.red
                                    : Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            if (authProvider.isLoggedIn) {
                              authProvider.toggleFavorite(restaurant.id);
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
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(0),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    //แสดงหมวดหมู่
                    Text(
                      restaurant.categories.join(', '),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),

                    //แสดงที่อยู่
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    //แสดงคะแนน
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < restaurant.rating.floor()
                                  ? Icons.star
                                  : index < restaurant.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '(${restaurant.rating.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
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
}
