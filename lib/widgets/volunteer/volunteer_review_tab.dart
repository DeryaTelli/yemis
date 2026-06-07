import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';
import '../food/food_review_item.dart';

class VolunteerReviewTab extends StatelessWidget {
  const VolunteerReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<VolunteerDetailViewModel>().reviews;
    if (reviews.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.volunteerDetail_noReviews.tr(),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: reviews.length,
      itemBuilder: (_, index) => FoodReviewItem(
        review: reviews[index],
        accentColor: AppColors.volunteerColor,
      ),
    );
  }
}
