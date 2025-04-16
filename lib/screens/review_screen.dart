import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../models/review_model.dart';

// หน้าจอสำหรับเพิ่มรีวิวร้านอาหาร
class AddReviewScreen extends StatefulWidget {
  final String restaurantId;

  AddReviewScreen({required this.restaurantId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // บันทึกรีวิว
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      // แสดงข้อความเตือนถ้าไม่ได้ให้คะแนน
      if (_rating == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('กรุณาให้คะแนนร้านอาหาร')));
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    try {
      // สร้างข้อมูลรีวิวใหม่
      final userProfile = authProvider.currentUser;

      if (userProfile != null) {
        final review = ReviewModel(
          id: '', // จะถูกสร้างโดย Firestore
          restaurantId: widget.restaurantId,
          userId: userProfile.uid,
          userName: userProfile.displayName ?? 'ผู้ใช้นิรนาม',
          userPhotoURL: userProfile.photoURL ?? '',
          comment: _commentController.text.trim(),
          rating: _rating.toDouble(),
          createdAt: DateTime.now(),
        );

        // บันทึกรีวิวลงฐานข้อมูล
        bool success = await restaurantProvider.addReview(review);

        if (success) {
          // ปิดหน้าจอเมื่อบันทึกสำเร็จ
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เพิ่มรีวิวเรียบร้อยแล้ว')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถเพิ่มรีวิวได้ กรุณาลองใหม่อีกครั้ง'),
            ),
          );
        }
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเพิ่มรีวิว: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เขียนรีวิว'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนให้คะแนนดาว
              Text(
                'ให้คะแนนร้านอาหาร',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),

              // ส่วนเขียนความคิดเห็น
              Text(
                'เขียนความคิดเห็น',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'แชร์ประสบการณ์ของคุณเกี่ยวกับร้านอาหารนี้...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาเขียนความคิดเห็น';
                  }
                  if (value.trim().length < 5) {
                    return 'ความคิดเห็นต้องมีความยาวอย่างน้อย 5 ตัวอักษร';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // ปุ่มบันทึกรีวิว
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child:
                      _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('บันทึกรีวิว', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
