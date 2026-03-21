import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class Co2RingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0

  Co2RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 5;
    const strokeWidth = 7.0;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = AppColors.primaryButtonGradient.createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2, // start: top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(Co2RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
