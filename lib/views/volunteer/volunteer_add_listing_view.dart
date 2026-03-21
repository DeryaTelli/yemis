import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_add_listing_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

/// Gönüllü ilan ekleme ekranı — Figma tasarımına uygun.
class VolunteerAddListingView extends StatelessWidget {
  const VolunteerAddListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerAddListingViewModel(),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerAddListingViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.volunteerAddListing_title.tr()),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fotoğraf ──────────────────────────────────────
            _label(LocaleKeys.volunteerAddListing_photoLabel.tr()),
            const SizedBox(height: 8),
            _PhotoBox(
              imagePath: vm.selectedImage?.path,
              onTap: () => _showImagePickerSheet(context, vm),
            ),
            const SizedBox(height: 24),

            // ── Bitiş Saati ───────────────────────────────────
            _label(LocaleKeys.volunteerAddListing_endTimeLabel.tr()),
            const SizedBox(height: 8),
            _TimeWheelSection(vm: vm),
            const SizedBox(height: 24),

            // ── Konum ─────────────────────────────────────────
            _label(LocaleKeys.volunteerAddListing_locationLabel.tr()),
            const SizedBox(height: 8),
            _LocationButton(vm: vm),
            const SizedBox(height: 20),

            // ── Fiyat ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label(LocaleKeys.volunteerAddListing_priceLabel.tr()),
                _FreeChip(),
              ],
            ),
            const SizedBox(height: 32),

            // ── Hata ──────────────────────────────────────────
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  LocaleKeys.volunteerAddListing_errorNoLocation.tr(),
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // ── Paylaş ────────────────────────────────────────
            _ShareButton(vm: vm),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: vm.selectedIndex,
        onItemSelected: (index) => _navigate(context, index),
        moduleType: AppModuleType.volunteer,
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      );

  void _showImagePickerSheet(
      BuildContext context, VolunteerAddListingViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.volunteerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.volunteerColor),
                ),
                title: Text(
                  LocaleKeys.volunteerAddListing_pickFromCamera.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.volunteerColor),
                onTap: () async {
                  Navigator.pop(context);
                  await vm.pickFromCamera();
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.volunteerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.volunteerColor),
                ),
                title: Text(
                  LocaleKeys.volunteerAddListing_pickFromGallery.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.volunteerColor),
                onTap: () async {
                  Navigator.pop(context);
                  await vm.pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (r) => false);
      return;
    }
    final map = {
      0: AppRoutes.volunteerHome,
      1: AppRoutes.volunteerSearch,
      3: AppRoutes.volunteerAddListing,
      4: AppRoutes.volunteerProfile,
    };
    final route = map[index];
    if (route != null && ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

// ─── Fotoğraf Kutusu ──────────────────────────────────────────────────────────
class _PhotoBox extends StatelessWidget {
  const _PhotoBox({required this.imagePath, required this.onTap});
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.volunteerColor.withValues(alpha: 0.5),
          borderRadius: 10,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 130,
          child: imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 130,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.volunteerColor.withValues(alpha: 0.8),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Saat Tekerleği ───────────────────────────────────────────────────────────
class _TimeWheelSection extends StatelessWidget {
  const _TimeWheelSection({required this.vm});
  final VolunteerAddListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // Seçili satır vurgusu
          Center(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Kolon'lar
          Row(
            children: [
              _WheelColumn(
                count: 12,
                initialItem: vm.selectedHour - 1,
                labelBuilder: (i) => '${i + 1}',
                onChanged: vm.onHourChanged,
              ),
              _WheelColumn(
                count: 60,
                initialItem: vm.selectedMinute,
                labelBuilder: (i) => i.toString().padLeft(2, '0'),
                onChanged: vm.onMinuteChanged,
              ),
              _WheelColumn(
                count: 2,
                initialItem: vm.isAm ? 0 : 1,
                labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                onChanged: vm.setAmPm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.count,
    required this.initialItem,
    required this.labelBuilder,
    required this.onChanged,
  });

  final int count;
  final int initialItem;
  final String Function(int) labelBuilder;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        diameterRatio: 1.4,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(
            child: Text(
              labelBuilder(i),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Konum Butonu ─────────────────────────────────────────────────────────────
class _LocationButton extends StatelessWidget {
  const _LocationButton({required this.vm});
  final VolunteerAddListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.pickLocation(context),
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.volunteerColor,
            width: 1.3,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          vm.hasLocation
              ? vm.locationAddress
              : LocaleKeys.volunteerAddListing_locationButton.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: vm.hasLocation
                ? AppColors.primaryTextColor
                : AppColors.primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Ücretsiz Chip ────────────────────────────────────────────────────────────
class _FreeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Text(
        LocaleKeys.volunteerAddListing_priceFree.tr(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      ),
    );
  }
}

// ─── Paylaş Butonu ────────────────────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.vm});
  final VolunteerAddListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: vm.isSubmitting
          ? null
          : () async {
              final ok = await vm.submit();
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        LocaleKeys.volunteerAddListing_successMessage.tr()),
                    backgroundColor: AppColors.volunteerColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
                vm.resetSuccess();
              }
            },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.volunteerBackgroundGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.volunteerColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: vm.isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                LocaleKeys.volunteerAddListing_shareButton.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
