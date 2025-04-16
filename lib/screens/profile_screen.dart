import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'restaurant_detail_screen.dart';

// หน้าจอแสดงข้อมูลโปรไฟล์ผู้ใช้
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RestaurantModel> _favoriteRestaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavoriteRestaurants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // โหลดรายการร้านอาหารโปรด
  Future<void> _loadFavoriteRestaurants() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ถ้ายังไม่ได้ล็อกอิน ไม่ต้องโหลดข้อมูล
    if (!authProvider.isLoggedIn) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    // ดึงข้อมูลร้านโปรดจากรายการ ID ร้านโปรดของผู้ใช้
    _favoriteRestaurants = await restaurantProvider.getRestaurantsByIds(
      authProvider.currentUser!.favorites,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // ตรวจสอบว่าผู้ใช้ล็อกอินแล้วหรือไม่
    if (!authProvider.isLoggedIn) {
      return _buildNotLoggedInScreen();
    }

    final user = authProvider.currentUser!;

    return Scaffold(
      body: Column(
        children: [
          // ส่วนหัวแสดงข้อมูลผู้ใช้
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30),

                // รูปโปรไฟล์
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 70, color: Colors.grey[600]),
                ),
                SizedBox(height: 15),

                // ชื่อผู้ใช้
                Text(
                  user.displayName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),

                // อีเมล
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),

                // ปุ่มแก้ไขโปรไฟล์
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(),
                          ),
                        )
                        .then((_) {
                          setState(() {});
                        });
                  },
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('แก้ไขโปรไฟล์'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // แถบแท็บ (ข้อมูลผู้ใช้และร้านโปรด)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [Tab(text: 'ข้อมูลผู้ใช้'), Tab(text: 'ร้านอาหารโปรด')],
            ),
          ),

          // เนื้อหาของแท็บ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // แท็บข้อมูลผู้ใช้
                _buildUserInfoTab(user),

                // แท็บร้านอาหารโปรด
                _buildFavoriteRestaurantsTab(),
              ],
            ),
          ),

          // ปุ่มออกจากระบบ
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutConfirmationDialog();
              },
              icon: Icon(Icons.exit_to_app),
              label: Text('ออกจากระบบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // สร้างแท็บข้อมูลผู้ใช้
  Widget _buildUserInfoTab(UserModel user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'ข้อมูลส่วนตัว',
            children: [
              _buildInfoItem(
                icon: Icons.person,
                label: 'ชื่อ',
                value: user.displayName,
              ),
              _buildInfoItem(
                icon: Icons.email,
                label: 'อีเมล',
                value: user.email,
              ),
              _buildInfoItem(
                icon: Icons.phone,
                label: 'เบอร์โทรศัพท์',
                value: user.phoneNumber,
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildInfoSection(
            title: 'ข้อมูลการใช้งาน',
            children: [
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'วันที่สมัคร',
                value:
                    user.createdAt != null
                        ? _formatDate(user.createdAt!)
                        : 'ไม่ระบุ',
              ),
              _buildInfoItem(
                icon: Icons.star,
                label: 'จำนวนรีวิว',
                value: user.reviewCount.toString(),
              ),
              _buildInfoItem(
                icon: Icons.favorite,
                label: 'ร้านอาหารโปรด',
                value: user.favorites.length.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // สร้างส่วนแสดงข้อมูล
  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        ...children,
      ],
    );
  }

  // สร้างรายการข้อมูล
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // สร้างแท็บร้านอาหารโปรด
  Widget _buildFavoriteRestaurantsTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _favoriteRestaurants.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 70, color: Colors.grey[400]),
              SizedBox(height: 15),
              Text(
                'ยังไม่มีร้านอาหารโปรด',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'กดปุ่มหัวใจที่ร้านอาหารเพื่อเพิ่มเข้ารายการโปรด',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _favoriteRestaurants.length,
          itemBuilder: (context, index) {
            return _buildRestaurantItem(_favoriteRestaurants[index]);
          },
        );
  }

  // สร้างหน้าสำหรับแสดงเมื่อยังไม่ได้ล็อกอิน
  Widget _buildNotLoggedInScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'คุณยังไม่ได้เข้าสู่ระบบ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'กรุณาเข้าสู่ระบบเพื่อดูข้อมูลโปรไฟล์',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              icon: Icon(Icons.login),
              label: Text('เข้าสู่ระบบ'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างรายการร้านอาหารสำหรับแสดงในแท็บร้านโปรด
  Widget _buildRestaurantItem(RestaurantModel restaurant) {
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
            // รูปร้านอาหาร
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                restaurant.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
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

            // ข้อมูลร้านอาหาร
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ชื่อร้าน
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

                        // ปุ่มลบออกจากรายการโปรด
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 22,
                              ),
                              onPressed: () async {
                                await authProvider.toggleFavorite(
                                  restaurant.id,
                                );
                                _loadFavoriteRestaurants();
                              },
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.all(0),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // หมวดหมู่
                    Text(
                      restaurant.categories.join(', '),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),

                    // ที่อยู่
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

                    // คะแนน
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

  // แสดงหน้าต่างยืนยันการออกจากระบบ
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ออกจากระบบ'),
            content: Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
                child: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // ฟอร์แมตวันที่ให้เป็นรูปแบบ วัน/เดือน/ปี
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
