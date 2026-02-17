import 'package:flutter/material.dart';
import '../utils/constants/app_colors.dart';
import '../utils/theme/text_styles_custom.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home View"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "1. SemiBold 16 Grey",
              style: CustomTextStyles.semiBold16Grey,
            ),
            const SizedBox(height: 10),
            Text(
              "2. Regular 14 Black",
              style: CustomTextStyles.regular14Black,
            ),
            const SizedBox(height: 10),
            Text(
              "3. Regular 14 Grey",
              style: CustomTextStyles.regular14Grey,
            ),
            const SizedBox(height: 20),
            // Example of using the gradient button concept (custom widget would be better)
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryButtonGradient,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  // 4. Bold 17 White for button
                  textStyle: CustomTextStyles.bold17White,
                ),
                child: const Text("4. Gradient Button"),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.yemoMessageBackground.withOpacity(0.2),
              child: Text(
                "5. This is a longer text example to show the line height of 24px (~1.71). It should be readable and have good spacing.",
                style: CustomTextStyles.regular14GreyHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
