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

    return Column(
      children: [
        // ── Slider ───────────────────────────────────────
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: vm.bannerController,
            onPageChanged: vm.onBannerPageChanged,
            itemCount: vm.banners.length,
            itemBuilder: (_, i) => BannerCard(banner: vm.banners[i]),
          ),
        ),

        const SizedBox(height: 14),

        // ── Dot İndikatörler ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(vm.banners.length, (index) {
            final isActive = index == vm.currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
