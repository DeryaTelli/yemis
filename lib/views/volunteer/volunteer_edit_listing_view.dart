import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_edit_listing_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/success_dialog_custom.dart';

class VolunteerEditListingView extends StatelessWidget {
  final VolunteerListing listing;
  const VolunteerEditListingView({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (ctx) => VolunteerEditListingViewModel(
          ctx.read<IAuthService>(),
          ctx.read<IVolunteerService>(),
          listing,
        ),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<VolunteerEditListingViewModel>();
    _titleController = TextEditingController(text: vm.title);
    _descriptionController = TextEditingController(text: vm.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerEditListingViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('İlanı Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('İlan Başlığı'),
            const SizedBox(height: 8),
            _InputField(
              controller: _titleController,
              hint: 'Örn: Sokak Hayvanları İçin Yemek',
              onChanged: vm.onTitleChanged,
            ),
            const SizedBox(height: 20),

            _label('Fotoğraf'),
            const SizedBox(height: 8),
            _PhotoBox(
              imagePath: vm.selectedImage?.path,
              existingImageUrl: vm.existingImageUrl,
              onTap: () => _showImagePickerSheet(context, vm),
            ),
            const SizedBox(height: 24),

            _label('Açıklama'),
            const SizedBox(height: 8),
            _InputField(
              controller: _descriptionController,
              hint: 'İlan içeriği hakkında bilgi veriniz...',
              maxLines: 3,
              onChanged: vm.onDescriptionChanged,
            ),
            const SizedBox(height: 24),

            _label('Bitiş Saati'),
            const SizedBox(height: 8),
            _TimeWheelSection(vm: vm),
            const SizedBox(height: 24),

            _label('Lokasyon'),
            const SizedBox(height: 8),
            _LocationButton(vm: vm),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('İlan Fiyatı'),
                _FreeChip(),
              ],
            ),
            const SizedBox(height: 32),

            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            _UpdateButton(vm: vm),
          ],
        ),
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

  void _showImagePickerSheet(BuildContext context, VolunteerEditListingViewModel vm) {
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
                    color: AppColors.volunteerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.volunteerColor),
                ),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.volunteerColor),
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
                    color: AppColors.volunteerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.volunteerColor),
                ),
                title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.volunteerColor),
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
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({this.imagePath, this.existingImageUrl, required this.onTap});
  final String? imagePath;
  final String? existingImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.volunteerColor.withOpacity(0.3), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imagePath != null
              ? Image.file(File(imagePath!), fit: BoxFit.cover)
              : (existingImageUrl != null && existingImageUrl!.isNotEmpty
                  ? (existingImageUrl!.startsWith('http')
                      ? Image.network(existingImageUrl!, fit: BoxFit.cover)
                      : Image.asset(existingImageUrl!, fit: BoxFit.cover))
                  : Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: AppColors.volunteerColor.withOpacity(0.5),
                      ),
                    )),
        ),
      ),
    );
  }
}

class _TimeWheelSection extends StatelessWidget {
  const _TimeWheelSection({required this.vm});
  final VolunteerEditListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
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
          Row(
            children: [
              _WheelColumn(count: 12, initialItem: vm.selectedHour - 1, labelBuilder: (i) => '${i + 1}', onChanged: vm.onHourChanged),
              _WheelColumn(count: 60, initialItem: vm.selectedMinute, labelBuilder: (i) => i.toString().padLeft(2, '0'), onChanged: vm.onMinuteChanged),
              _WheelColumn(count: 2, initialItem: vm.isAm ? 0 : 1, labelBuilder: (i) => i == 0 ? 'AM' : 'PM', onChanged: vm.setAmPm),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({required this.count, required this.initialItem, required this.labelBuilder, required this.onChanged});
  final int count;
  final int initialItem;
  final String Function(int) labelBuilder;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        diameterRatio: 1.4,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: List.generate(count, (i) => Center(child: Text(labelBuilder(i), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  const _LocationButton({required this.vm});
  final VolunteerEditListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    final bool hasData = vm.locationAddress.isNotEmpty;
    return GestureDetector(
      onTap: () => vm.pickLocation(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.volunteerColor, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(hasData ? vm.locationAddress : 'Lokasyon Seç', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.hintTextColor),
          ],
        ),
      ),
    );
  }
}

class _FreeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDDDDDD))),
      child: const Text('Ücretsiz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.vm});
  final VolunteerEditListingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: vm.isSubmitting ? null : () async {
        final ok = await vm.update();
        if (ok && context.mounted) {
          SuccessDialogCustom.show(
            context,
            title: 'Güncellendi',
            message: 'İlan başarıyla güncellendi.',
            onConfirm: () => Navigator.pop(context, true),
          );
        } else if (context.mounted && vm.errorMessage != null) {
          ErrorDialogCustom.show(context, message: vm.errorMessage!);
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.volunteerBackgroundGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.volunteerColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: vm.isSubmitting
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Güncelle', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.hint, required this.onChanged, this.controller, this.maxLines = 1});
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.volunteerColor.withOpacity(0.2), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.volunteerColor, width: 1.5)),
      ),
    );
  }
}
