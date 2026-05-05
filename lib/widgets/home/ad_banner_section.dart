import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'banner_card.dart';

/// Banner slider + dot indikatörleri içeren bölüm.
/// HomeViewModel'i dinler; sayfa değişiminde dot'lar güncellenir.
class AdBannerSection extends StatelessWidget {
  const AdBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.32;

    return Stack(
      children: [
        // ── Slider ───────────────────────────────────────
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: vm.bannerController,
            onPageChanged: vm.onBannerPageChanged,
            itemCount: vm.banners.length,
            itemBuilder: (_, i) => BannerCard(banner: vm.banners[i]),
          ),
        ),

        // ── Dot İndikatörler (Banner Üzerinde, Sağ Alt) ──
        Positioned(
          right: 24,
          bottom: 0.1, // Metnin hemen altında veya hizasında
          child: AnimatedBuilder(
            animation: vm.bannerController,
            builder: (context, _) {
              double page = 0;
              if (vm.bannerController.hasClients) {
                page = vm.bannerController.page ?? 0;
              } else {
                page = vm.currentBannerIndex.toDouble();
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(vm.banners.length, (index) {
                  // Mevcut sayfaya olan uzaklık
                  final distance = (page - index).abs();
                  // 0.0 (tam üstünde) -> 1.0 (bir sayfa uzak)
                  // Boyut ve opaklığı mesafeye göre ayarla
                  final double scale = (1.0 - (distance * 0.5)).clamp(0.5, 1.0);
                  final double opacity = (1.0 - (distance * 0.7)).clamp(
                    0.3,
                    1.0,
                  );

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12 * scale + (index == page.round() ? 4 : 0),
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
