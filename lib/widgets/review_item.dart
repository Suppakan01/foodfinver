import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';

class ReviewItem extends StatelessWidget {
  final ReviewModel review;
  final bool showRestaurantInfo;
  final VoidCallback? onTap;

  const ReviewItem({
    Key? key,
    required this.review,
    this.showRestaurantInfo = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนข้อมูลผู้รีวิว
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปโปรไฟล์ผู้รีวิว
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        review.userPhotoURL.isNotEmpty
                            ? NetworkImage(review.userPhotoURL)
                            : null,
                    child:
                        review.userPhotoURL.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                  ),

                  const SizedBox(width: 12),

                  // ข้อมูลผู้รีวิวและคะแนน
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildRatingStars(review.rating),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // วันที่รีวิว
                        Text(
                          DateFormat(
                            'd MMM yyyy เวลา HH:mm',
                          ).format(review.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ข้อความรีวิว
              Text(review.comment, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // สร้างแถบแสดงคะแนนดาว
  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating
                ? Icons.star
                : i - 0.5 <= rating
                ? Icons.star_half
                : Icons.star_border,
            color: Colors.amber,
            size: 16,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
