import 'package:flutter/material.dart';

class VolunteerReviewTab extends StatelessWidget {
  const VolunteerReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Henüz yorum bulunmamaktadır.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
