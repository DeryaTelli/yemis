import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';

/// Gönüllü harita alanını gösterir.
class VolunteerMapSection extends StatelessWidget {
  const VolunteerMapSection({super.key, this.listings = const []});

  final List<VolunteerListing> listings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Gerçekçi Harita Arka Planı (Painter) ────────
            Container(
              color: const Color(0xFFF2F2F2),
              child: CustomPaint(painter: _RealisticMapPainter()),
            ),

            // ── Merkez Konum Pin (Green Teardrop) ─────────
            const Center(child: _MapPinTeardrop(isCenter: true)),

            // ── Konum Bul Butonu (sağ alt) ───────────
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.volunteerColor,
                  size: 20,
                ),
              ),
            ),

            // ── İlan Pinleri (dağıtılmış) ────────────────
            ..._getMockPositions(listings.length).map(
              (pos) => Positioned(
                left: pos.dx,
                top: pos.dy,
                child: const _MapPinTeardrop(isCenter: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Offset> _getMockPositions(int count) {
    const basePositions = [
      Offset(40, 50),
      Offset(240, 40),
      Offset(280, 160),
      Offset(70, 180),
      Offset(160, 210),
    ];
    return basePositions.take(count).toList();
  }
}

/// Green Teardrop Pin
class _MapPinTeardrop extends StatelessWidget {
  const _MapPinTeardrop({this.isCenter = false});

  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCenter ? 32 : 24,
          height: isCenter ? 32 : 24,
          decoration: BoxDecoration(
            color: AppColors.volunteerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.volunteerColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isCenter ? Icons.location_on : Icons.volunteer_activism_rounded,
              size: isCenter ? 18 : 12,
              color: Colors.white,
            ),
          ),
        ),
        // Alt Teardrop kuyruğu
        CustomPaint(
          size: const Size(8, 6),
          painter: _TeardropTailPainter(color: AppColors.volunteerColor),
        ),
      ],
    );
  }
}

class _TeardropTailPainter extends CustomPainter {
  _TeardropTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Gerçekçi Harita Çizgisi (Painter) ───────────────
class _RealisticMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final areaPaint = Paint()
      ..color = const Color(0xFFE8EAE6)
      ..style = PaintingStyle.fill;

    final parkPaint = Paint()
      ..color = const Color(0xFFDAE8D1)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF1F1F1),
    );

    canvas.drawRRect(
      RRect.fromLTRBR(20, 30, 80, 100, const Radius.circular(20)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width - 100,
        150,
        size.width - 20,
        230,
        const Radius.circular(20),
      ),
      parkPaint,
    );

    canvas.drawLine(const Offset(0, 100), Offset(size.width, 100), streetPaint);
    canvas.drawLine(
      const Offset(100, 0),
      Offset(100, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.3, size.height),
      streetPaint,
    );

    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      const Offset(0, 50),
      Offset(size.width, 180),
      mainRoadPaint,
    );

    _drawLabel(canvas, "Şirinevler", const Offset(110, 80));
    _drawLabel(canvas, "Ergenekon", const Offset(150, 160));
    _drawLabel(canvas, "Karabük", const Offset(180, 200));
    _drawLabel(canvas, "Kurtuluş", const Offset(230, 40));
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_) => false;
}
