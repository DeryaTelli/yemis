import 'package:flutter/material.dart';

/// Home ekranındaki navigasyon kartı modeli.
/// Hangi modüle gidileceğini, görsel tasarımını ve
/// PNG ikonun yerini (sağ/sol) tanımlar.
class HomeCardItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final String route;
  final LinearGradient gradient;

  /// true  → PNG sol tarafta taşar, metin sağda (Yemek / İşletme)
  /// false → PNG sağ tarafta taşar, metin solda (Gönüllü Ol)
  final bool imageOnLeft;

  const HomeCardItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.route,
    required this.gradient,
    required this.imageOnLeft,
  });
}
