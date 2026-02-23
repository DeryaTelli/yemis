import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';
import 'food_review_item.dart';

/// Food Detay → Yorum sekmesi içeriği.
class FoodReviewTab extends StatelessWidget {
  const FoodReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodDetailViewModel>();
    final reviews = vm.reviews;

    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined,
                  color: AppColors.hintTextColor, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Henüz yorum yapılmamış.',
                style: TextStyle(color: AppColors.hintTextColor, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: reviews.length,
      itemBuilder: (context, index) => FoodReviewItem(review: reviews[index]),
    );
  }
}
