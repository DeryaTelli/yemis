import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import 'dashed_border_painter.dart';

class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.networkImageUrl,
  });
  
  final String? imagePath;
  final String? networkImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          borderRadius: 10,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 130,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 130,
        ),
      );
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          networkImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 130,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 40,
        color: AppColors.primaryColor.withValues(alpha: 0.8),
      ),
    );
  }
}
