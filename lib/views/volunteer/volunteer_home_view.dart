import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// Gönüllü ana sayfası — ileride dolu içerik gelecek
class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.volunteerColor,
        foregroundColor: Colors.white,
        title: const Text('Gönüllü Ol'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism,
                size: 72, color: AppColors.volunteerColor),
            SizedBox(height: 16),
            Text(
              'Gönüllü sayfası yakında!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.volunteerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
