import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// Harita alanını gösterir.
/// Şimdilik mock bir harita tile'ı kullanır.
/// İleride flutter_map veya google_maps_flutter ile değiştirilebilir.
class FoodMapSection extends StatelessWidget {
  const FoodMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Mock Harita Arka Planı ───────────────
            Container(
              color: const Color(0xFFE8EAE6),
              child: CustomPaint(
                painter: _MockMapPainter(),
              ),
            ),

            // ── Konum Pin İkonu ──────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 16,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),

            // ── Konum Bul Butonu (sağ alt) ───────────
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
              ),
            ),

            // ── Yakın Yer Pinleri (mock) ─────────────
            ..._mockPins.map((pin) => Positioned(
                  left: pin.dx,
                  top: pin.dy,
                  child: const _MapPin(),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Mock Pin Veri ─────────────────────────────────────
class _PinData {
  const _PinData(this.dx, this.dy);
  final double dx;
  final double dy;
}

const List<_PinData> _mockPins = [
  _PinData(60, 80),
  _PinData(200, 50),
  _PinData(260, 150),
  _PinData(80, 220),
];

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_rounded, color: Colors.white, size: 14),
        ],
      ),
    );
  }
}

// ─── Mock Harita Çizgisi ────────────────────────────────
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Yatay çizgiler (sokaklar)
    for (double y = 40; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Dikey çizgiler
    for (double x = 50; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Çapraz cadde
    paint.strokeWidth = 3;
    canvas.drawLine(
      const Offset(0, 80),
      Offset(size.width, size.height - 80),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
