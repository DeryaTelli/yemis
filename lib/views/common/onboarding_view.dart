import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final Color colorStart;
  final Color colorEnd;
  final IconData icon;
  final String? lottieUrl;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.colorStart,
    required this.colorEnd,
    required this.icon,
    this.lottieUrl,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _emojiController;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: LocaleKeys.onboarding_page1_title.tr(),
      subtitle: LocaleKeys.onboarding_page1_subtitle.tr(),
      description: LocaleKeys.onboarding_page1_description.tr(),
      emoji: "🥙",
      colorStart: const Color(0xFFFB923C),
      colorEnd: const Color(0xFFF97316),
      icon: Icons.restaurant,
      lottieUrl: "assets/lottie/onboarding1.json",
    ),
    OnboardingPage(
      title: LocaleKeys.onboarding_page2_title.tr(),
      subtitle: LocaleKeys.onboarding_page2_subtitle.tr(),
      description: LocaleKeys.onboarding_page2_description.tr(),
      emoji: "🛒",
      colorStart: const Color(0xFFF97316),
      colorEnd: const Color(0xFFF59E0B),
      icon: Icons.store,
      lottieUrl: "assets/lottie/onboarding2.json",
    ),
    OnboardingPage(
      title: LocaleKeys.onboarding_page3_title.tr(),
      subtitle: LocaleKeys.onboarding_page3_subtitle.tr(),
      description: LocaleKeys.onboarding_page3_description.tr(),
      emoji: "❤️",
      colorStart: const Color(0xFF10B981),
      colorEnd: const Color(0xFF059669),
      icon: Icons.favorite,
      lottieUrl: "assets/lottie/onboarding3_3.json",
    ),
    OnboardingPage(
      title: LocaleKeys.onboarding_page4_title.tr(),
      subtitle: LocaleKeys.onboarding_page4_subtitle.tr(),
      description: LocaleKeys.onboarding_page4_description.tr(),
      emoji: "🌿",
      colorStart: const Color(0xFF059669),
      colorEnd: const Color(0xFF047857),
      icon: Icons.eco,
      lottieUrl: "assets/lottie/onboarding4.json",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _emojiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildPage(pages[index]);
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                LocaleKeys.onboarding_buttons_skip.tr(),
                style: CustomTextStyles.semiBold16DarkGreyCompact.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Back button
                      if (_currentPage > 0)
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pages[_currentPage].colorStart
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: pages[_currentPage].colorStart,
                              ),
                              onPressed: _previousPage,
                            ),
                          ),
                        ),

                      // Next button
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              pages[_currentPage].colorStart,
                              pages[_currentPage].colorEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: pages[_currentPage].colorStart.withOpacity(
                                0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage < pages.length - 1
                                    ? LocaleKeys.onboarding_buttons_next.tr()
                                    : LocaleKeys.onboarding_buttons_start.tr(),
                                style: CustomTextStyles
                                    .semiBold16DarkGreyCompact
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      children: [
        // Top section with gradient and wave
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [page.colorStart, page.colorEnd],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: 32,
                      left: 32,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.2),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.1 + (_pulseController.value * 0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 64,
                      right: 48,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.3 - (_pulseController.value * 0.3),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.1 + (_pulseController.value * 0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Wave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _waveController.value * 5),
                      child: CustomPaint(
                        size: const Size(double.infinity, 60),
                        painter: WavePainter(),
                      ),
                    );
                  },
                ),
              ),

              // Center icon/animation
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.2),
                          child: Container(
                            width: 224,
                            height: 224,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  0.2 - (_pulseController.value * 0.2),
                                ),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Icon or Lottie
                    Container(
                      width: 224,
                      height: 224,
                      alignment: Alignment.center,
                      child: page.lottieUrl != null
                          ? (page.lottieUrl!.startsWith('http')
                                ? Lottie.network(
                                    page.lottieUrl!,
                                    width: 224,
                                    height: 224,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildFallbackIcon(page);
                                    },
                                  )
                                : Lottie.asset(
                                    page.lottieUrl!,
                                    width: 224,
                                    height: 224,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildFallbackIcon(page);
                                    },
                                  ))
                          : _buildFallbackIcon(page),
                    ),

                    // Emoji badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _emojiController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_emojiController.value * 0.2),
                            child: Transform.rotate(
                              angle: (_emojiController.value - 0.5) * 0.3,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    page.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content section
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: page.colorStart,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  page.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon(OnboardingPage page) {
    return Container(
      width: 144,
      height: 144,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [page.colorStart, page.colorEnd],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: page.colorStart.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(page.icon, size: 72, color: Colors.white),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? pages[_currentPage].colorStart : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 1.2,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
