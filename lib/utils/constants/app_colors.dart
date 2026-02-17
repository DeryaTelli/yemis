import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // 1. Uygulamanın genel rengi (Orange)
  static const Color primaryColor = Color(0xFFFE8800);

  // 2. Silik textbox yazısı (Grey)
  static const Color hintTextColor = Color(0xFF838383);

  // 3. Normal text yazısı (Dark Grey/Black)
  static const Color primaryTextColor = Color(0xFF1B1B1B);

  // 4. Button Rengi (Gradient)
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [
      Color(0xFFFEC380), // 0%
      Color(0xFFFEA033), // 17%
      Color(0xFFFE8800), // 100%
    ],
    stops: [0.0, 0.17, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 5. Seçilmemiş buton yazısı (Black with 70% opacity)
  static const Color unselectedButtonTextColor = Color(0xB3000000); // 0xB3 is approx 70% alpha

  // 6. Ana uygulama geçiş yeri arka plan rengi (Orange Gradient)
  static const LinearGradient mainAppTransitionBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFEA033), // 17%
      Color(0xFFF7AF5B), // 25%
      Color(0xFFFE8800), // 80%
    ],
    stops: [0.17, 0.25, 0.80],
    begin: Alignment.centerLeft, // Assuming linear default
    end: Alignment.centerRight,
  );

  // 7. Gönüllü ol yeri arka planı (Green Gradient)
  static const LinearGradient volunteerBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF22B05A), // 0%
      Color(0xFF24F276), // 39%
      Color(0xFF22B05A), // 100%
    ],
    stops: [0.0, 0.39, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 8. Lokasyonun çizgisinin rengi (Orange with 70% opacity)
  static const Color locationLineColor = Color(0xB3EF9F27); // 0xB3 is approx 70% alpha

  // 9. Yorum yerinin backgroundu ve profil sayfasındaki ayarların yeri (Orange with 30% opacity)
  static const Color commentAndSettingsBackground = Color(0x4DD79C1D); // 0x4D is approx 30% alpha

  // 10. Yemo yapay zekasının yazdığı mesaj kutusunun arka planı (Orange)
  static const Color yemoMessageBackground = Color(0xFFEF9F27);
}
