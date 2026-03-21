import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/locale_keys.dart';

class VolunteerReviewTab extends StatelessWidget {
  const VolunteerReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.volunteerDetail_noReviews.tr(),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
