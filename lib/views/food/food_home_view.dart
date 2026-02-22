import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// Yemek ana sayfası — ileride dolu içerik gelecek
class FoodHomeView extends StatelessWidget {
  const FoodHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Yemek'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu,
                size: 72, color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text(
              'Yemek sayfası yakında!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
