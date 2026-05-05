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
      subtitle: 'Yemis kullanarak dünya yemek israfının önüne geç!',
      fromColor: Color(0xFFFEC380),
      toColor: Color(0xFFFE8800),
      imagePath: 'assets/foodIcon/yemo.png',
    ),
    AdBanner(
      title: 'Taze Kal',
      subtitle: 'İsrafı önle, bütçeni koru ve\ndoğaya katkıda bulun.',
      fromColor: Color(0xFF81FBB8),
      toColor: Color(0xFF28C76F),
      imagePath: 'assets/foodIcon/yemo.png',
    ),
    AdBanner(
      title: 'Paylaş',
      subtitle: 'Fazla yemeğini paylaşarak\nbir gülümsemeye vesile ol.',
      fromColor: Color(0xFFABDCFF),
      toColor: Color(0xFF0396FF),
      imagePath: 'assets/foodIcon/yemo.png',
    ),
    AdBanner(
      title: 'Keşfet',
      subtitle: 'Çevrendeki fırsatları gör,\nen uygun fiyatlarla doy!',
      fromColor: Color(0xFFFEB692),
      toColor: Color(0xFFEA5455),
      imagePath: 'assets/foodIcon/yemo.png',
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
