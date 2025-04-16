import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant_model.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = [];
  List<String> _suggestedCategories = [
    'อาหารไทย',
    'อาหารจีน',
    'อาหารญี่ปุ่น',
    'อาหารอิตาเลียน',
    'อาหารฟาสต์ฟู้ด',
    'ร้านกาแฟ',
    'ร้านเบเกอรี่',
    'อาหารเจ',
    'อาหารมังสวิรัติ',
    'บุฟเฟ่ต์',
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    // เรียกข้อมูลร้านอาหารเมื่อเข้าหน้าค้นหา (ถ้าไม่มีข้อมูลในแคช)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );
      if (restaurantProvider.restaurants.isEmpty) {
        restaurantProvider.fetchRestaurants();
      }
    });

    // เพิ่ม listener สำหรับการค้นหาทันที
    _searchController.addListener(_onSearchChanged);
  }

  // โหลดประวัติการค้นหาล่าสุด (จริงๆ ควรใช้ SharedPreferences)
  void _loadRecentSearches() {
    // สมมติว่าใช้ข้อมูลนี้เป็นประวัติการค้นหา
    setState(() {
      _recentSearches = ['ส้มตำ', 'ชาบู', 'พิซซ่า', 'อาหารเกาหลี'];
    });
  }

  // บันทึกคำค้นหาล่าสุด
  void _saveSearchQuery(String query) {
    if (query.isEmpty) return;

    setState(() {
      // ลบคำค้นหาเดิม (ถ้ามี) แล้วเพิ่มใหม่ที่ตำแหน่งแรก
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);

      // จำกัดจำนวนประวัติการค้นหาไม่เกิน 10 รายการ
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  // เมื่อข้อความในช่องค้นหาเปลี่ยนแปลง
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });

    // ค้นหาร้านอาหารตามคำค้นหา
    if (_searchQuery.isNotEmpty) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).searchRestaurants(_searchQuery);
    }
  }

  // เมื่อกดปุ่มค้นหา
  void _onSubmitted(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isNotEmpty) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).searchRestaurants(query);
      _saveSearchQuery(query);
    }
  }

  // เมื่อเลือกคำค้นหาจากประวัติหรือคำแนะนำ
  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSubmitted(suggestion);
  }

  // เมื่อเลือกร้านอาหาร
  void _onRestaurantTap(BuildContext context, RestaurantModel restaurant) {
    Navigator.of(context).pushNamed(
      'RestaurantDetailScreen.routeName',
      arguments: {'restaurantId': restaurant.id},
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final searchResults = restaurantProvider.searchResults;
    final isLoading = restaurantProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ค้นหาร้านอาหาร, ประเภทอาหาร...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, color: Colors.orange),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSubmitted,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchQuery.isEmpty
              ? _buildSuggestions()
              : _buildSearchResults(searchResults),
    );
  }

  // แสดงคำแนะนำในการค้นหา
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ประวัติการค้นหาล่าสุด
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ค้นหาล่าสุด',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches = [];
                    });
                  },
                  child: const Text(
                    'ล้างทั้งหมด',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _recentSearches.map((search) {
                    return InputChip(
                      label: Text(search),
                      backgroundColor: Colors.grey[200],
                      onPressed: () => _onSuggestionTap(search),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _recentSearches.remove(search);
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // หมวดหมู่อาหารแนะนำ
          const Text(
            'หมวดหมู่อาหาร',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _suggestedCategories.map((category) {
                  return ActionChip(
                    label: Text(category),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(color: Colors.orange),
                    onPressed: () => _onSuggestionTap(category),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // แสดงผลการค้นหา
  Widget _buildSearchResults(List<RestaurantModel> searchResults) {
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ไม่พบร้านอาหารที่ตรงกับ "$_searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'ลองค้นหาด้วยคำอื่น หรือหมวดหมู่อาหาร',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final restaurant = searchResults[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () => _onRestaurantTap(context, restaurant),
        );
      },
    );
  }
}
