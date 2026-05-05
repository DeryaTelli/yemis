import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  const WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Sol alttan başlıyor, içeriden yukarı kıvrılıyor
    path.moveTo(0, size.height * 0.78);

    // İç bükey, yumuşak yukarı çıkan eğim
    path.quadraticBezierTo(
      size.width * 0.29,
      size.height * 0.10,
      size.width,
      size.height * 0.0001,
    );

    // Beyaz alanı alta tamamla
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
