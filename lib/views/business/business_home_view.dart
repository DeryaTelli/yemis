import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// İşletme ana sayfası — ileride dolu içerik gelecek
class BusinessHomeView extends StatelessWidget {
  const BusinessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('İşletme'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 72, color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text(
              'İşletme paneli yakında!',
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
