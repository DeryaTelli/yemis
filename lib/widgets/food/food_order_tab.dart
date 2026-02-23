import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';

/// Food Detay → Sipariş sekmesi içeriği.
class FoodOrderTab extends StatelessWidget {
  const FoodOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodDetailViewModel>();
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ürün Başlığı ──────────────────────────────
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // ── Açıklama ──────────────────────────────────
          if (listing.description != null)
            Text(
              listing.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.hintTextColor,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),

          // ── Harita Thumbnail ──────────────────────────
          _MapThumbnail(),
          const SizedBox(height: 12),

          // ── Lokasyona Git Butonu ───────────────────────
          _GoToLocationButton(),
          const SizedBox(height: 20),

          // ── Daha Fazla Detay (Expandable) ─────────────
          _ExpandableDetail(vm: vm, listing: listing),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Harita Placeholder
// ─────────────────────────────────────────────────────
class _MapThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        color: const Color(0xFFE8E8E8),
        child: Stack(
          children: [
            // Harita arka planı (placeholder renk grid)
            CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _MapGridPainter(),
            ),
            // Merkez pin
            const Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 36,
              ),
            ),
            // Apple Maps watermark benzeri logo
            Positioned(
              bottom: 6,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '⊙ Maps',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Basit bir harita grid çizgisi — gerçek harita yokken placeholder olarak kullanılır.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFD4E6A5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    // Yatay yollar
    for (double y = 20; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Dikey yollar
    for (double x = 30; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────
// Lokasyona Git Butonu
// ─────────────────────────────────────────────────────
class _GoToLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Harita uygulamasını aç (url_launcher)
      },
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          LocaleKeys.foodDetail_goToLocation.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Genişleyen Detay Bölümü
// ─────────────────────────────────────────────────────
class _ExpandableDetail extends StatelessWidget {
  const _ExpandableDetail({required this.vm, required this.listing});

  final FoodDetailViewModel vm;
  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          GestureDetector(
            onTap: vm.toggleDetailExpanded,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.foodDetail_moreDetail.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  AnimatedRotation(
                    turns: vm.isDetailExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İçerik (genişlediğinde görünür)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.foodDetail_ingredients.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (listing.ingredients != null)
                    Text(
                      listing.ingredients!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.hintTextColor,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: vm.isDetailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
