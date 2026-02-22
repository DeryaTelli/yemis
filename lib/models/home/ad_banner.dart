import 'package:flutter/material.dart';

/// Reklam banner modeli. Sadece veri taşır, UI mantığı içermez.
class AdBanner {
  final String title;
  final String subtitle;
  final Color fromColor;
  final Color toColor;
  final String imagePath;

  const AdBanner({
    required this.title,
    required this.subtitle,
    required this.fromColor,
    required this.toColor,
    required this.imagePath,
  });
}
