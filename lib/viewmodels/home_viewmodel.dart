import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
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
      title: LocaleKeys.volunteer_becomeButton.tr(),
      subtitle: LocaleKeys.home_volunteerSubtitle.tr(),
      imagePath: 'assets/foodIcon/volunteerSide.png',
      route: AppRoutes.volunteerHome,
      gradient: AppColors.volunteerBackgroundGradient,
      imageOnLeft: false,
    );

    if (userType == UserType.food) {
      return [
        HomeCardItem(
          title: LocaleKeys.home_foodTitle.tr(),
          subtitle: LocaleKeys.home_foodSubtitle.tr(),
          imagePath: 'assets/foodIcon/foodSide.png',
          route: AppRoutes.foodHome,
          gradient: AppColors.mainAppTransitionBackgroundGradient,
          imageOnLeft: true,
        ),
        volunteerCard,
      ];
    } else {
      return [
        HomeCardItem(
          title: LocaleKeys.home_businessTitle.tr(),
          subtitle: LocaleKeys.home_businessSubtitle.tr(),
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

  final List<AdBanner> banners = [
    AdBanner(
      title: 'Yemis',
      subtitle: LocaleKeys.home_onboarding1Subtitle.tr(),
      fromColor: const Color(0xFFFEC380),
      toColor: const Color(0xFFFE8800),
      imagePath: 'assets/common/poster1_2.png',
    ),
    AdBanner(
      title: LocaleKeys.home_onboarding2Title.tr(),
      subtitle: LocaleKeys.home_onboarding2Subtitle.tr(),
      fromColor: const Color(0xFF81FBB8),
      toColor: const Color(0xFF28C76F),
      imagePath: 'assets/common/poster1_3.png',
    ),
    AdBanner(
      title: LocaleKeys.home_onboarding3Title.tr(),
      subtitle: LocaleKeys.home_onboarding3Subtitle.tr(),
      fromColor: const Color(0xFFABDCFF),
      toColor: const Color(0xFF0396FF),
      imagePath: 'assets/common/poster1_1.png',
    ),
    AdBanner(
      title: LocaleKeys.home_onboarding4Title.tr(),
      subtitle: LocaleKeys.home_onboarding4Subtitle.tr(),
      fromColor: const Color(0xFFFEB692),
      toColor: const Color(0xFFEA5455),
      imagePath: 'assets/common/poster1_4.png',
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
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
