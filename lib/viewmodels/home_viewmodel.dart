import 'dart:async';
import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../models/home/ad_banner.dart';
import '../models/home/home_card_item.dart';
import '../utils/constants/app_colors.dart';
import '../utils/routes/app_routes.dart';

/// Home ekranının ViewModel'i.
///
/// Sorumluluklar:
/// - Kullanıcı tipine göre navigasyon kartlarını döner
/// - Reklam banner listesini tutar
/// - Banner otomatik kaydırma zamanlayıcısını yönetir
class HomeViewModel extends ChangeNotifier {
  final UserType userType;

  HomeViewModel({this.userType = UserType.food});

  // ─── Navigasyon Kartları ───────────────────────────────

  /// Food kullanıcısı → Yemek + Gönüllü
  /// Business kullanıcısı → İşletme + Gönüllü
  List<HomeCardItem> get cards {
    final volunteerCard = HomeCardItem(
      title: 'Gönüllü Ol',
      subtitle: 'Evde kalan yemekleri paylaş!',
      imagePath: 'assets/foodIcon/volunteerSide.png',
      route: AppRoutes.volunteerHome,
      gradient: AppColors.volunteerBackgroundGradient,
      imageOnLeft: false,
    );

    if (userType == UserType.food) {
      return [
        const HomeCardItem(
          title: 'Yemek',
          subtitle: 'Uygun fiyata yemek al israfın önüne geç!',
          imagePath: 'assets/foodIcon/foodSide.png',
          route: AppRoutes.foodHome,
          gradient: AppColors.mainAppTransitionBackgroundGradient,
          imageOnLeft: true,
        ),
        volunteerCard,
      ];
    } else {
      return [
        const HomeCardItem(
          title: 'İşletme',
          subtitle: 'Menünü yönet, israfı azalt!',
          imagePath: 'assets/foodIcon/foodSide.png',
          route: AppRoutes.businessHome,
          gradient: AppColors.mainAppTransitionBackgroundGradient,
          imageOnLeft: true,
        ),
        volunteerCard,
      ];
    }
  }

  // ─── Banner ────────────────────────────────────────────

  final PageController bannerController = PageController();

  final List<AdBanner> banners = const [
    AdBanner(
      title: 'Yemis',
      subtitle: 'Yemis kullanarak dünya yemek\nisrafının önüne geç!',
      fromColor: Color(0xFFFEC380),
      toColor: Color(0xFFFE8800),
      imagePath: 'assets/foodIcon/foodLocationPoint.png',
    ),
    AdBanner(
      title: 'Sıfır İsraf',
      subtitle: 'Her gün milyonlarca porsiyon\nyemek çöpe gidiyor.',
      fromColor: Color(0xFFFFB347),
      toColor: Color(0xFFFF6B00),
      imagePath: 'assets/foodIcon/foodLocationPoint.png',
    ),
    AdBanner(
      title: 'Komşuna Ulaş',
      subtitle: 'Yakınındaki insanlara\nyemek bağışla.',
      fromColor: Color(0xFF56CCF2),
      toColor: Color(0xFF2F80ED),
      imagePath: 'assets/foodIcon/foodLocationPoint.png',
    ),
    AdBanner(
      title: 'Kazanmaya Başla',
      subtitle: 'Her paylaşımda puan biriktir,\nödül kazan!',
      fromColor: Color(0xFF6FCF97),
      toColor: Color(0xFF219653),
      imagePath: 'assets/foodIcon/foodLocationPoint.png',
    ),
  ];

  int _currentBannerIndex = 0;
  int get currentBannerIndex => _currentBannerIndex;

  Timer? _autoScrollTimer;

  void startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_currentBannerIndex + 1) % banners.length;
      bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void stopAutoScroll() => _autoScrollTimer?.cancel();

  int _selectedIndex = 2;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void onBannerPageChanged(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  // ─── Dispose ───────────────────────────────────────────

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    bannerController.dispose();
    super.dispose();
  }
}
