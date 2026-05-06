// ignore: unused_import
import 'dart:io'; // Required for Image.file() which takes dart:io.File
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/food/food_profile_viewmodel.dart';
import '../../utils/constants/app_colors.dart';
import '../../models/app_module_type.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_text_field.dart';

class FoodProfileEditView extends StatelessWidget {
  const FoodProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FoodProfileEditBody();
  }
}

class _FoodProfileEditBody extends StatefulWidget {
  const _FoodProfileEditBody();

  @override
  State<_FoodProfileEditBody> createState() => _FoodProfileEditBodyState();
}

class _FoodProfileEditBodyState extends State<_FoodProfileEditBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProfileViewModel>().fetchProfile();
    });
  }

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(###) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodProfileViewModel>();

    final primaryColor = Theme.of(context).primaryColor;

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: primaryColor == AppColors.volunteerColor
          ? AppModuleType.volunteer
          : AppModuleType.food,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(LocaleKeys.foodProfile_editTitle.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // ─── Profil Fotoğrafı ──────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => _showPhotoSelectBS(context, vm),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(child: _buildAvatar(vm, primaryColor)),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ─── Form Alanları ─────────────────────────
              CustomTextField(
                controller: vm.fullNameController,
                labelText: LocaleKeys.common_fullName.tr(),
                hintText: LocaleKeys.auth_fields_fullNameHint.tr(),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: vm.emailController,
                labelText: LocaleKeys.auth_fields_email.tr(),
                hintText: LocaleKeys.auth_fields_emailHint.tr(),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: vm.phoneController,
                labelText: LocaleKeys.auth_fields_phone.tr(),
                hintText: '(5XX) XXX XX XX',
                prefixText: '+90 ',
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMaskFormatter],
              ),
              const SizedBox(height: 40),

              // ─── Aksiyon Butonları ─────────────────────
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: primaryColor == AppColors.volunteerColor
                        ? AppColors.volunteerBackgroundGradient
                        : AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      vm.updateAccount(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      LocaleKeys.foodProfile_updateButton.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => vm.deleteAccount(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.volunteerProfile_deleteAccount.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(FoodProfileViewModel vm, Color primaryColor) {
    // 1. Öncelik: Yerel seçilen dosya
    if (vm.selectedImageFile != null) {
      return Image.file(
        vm.selectedImageFile!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
    // 2. Öncelik: API'den gelen URL
    if (vm.remoteImageUrl != null && vm.remoteImageUrl!.isNotEmpty) {
      return Image.network(
        vm.remoteImageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.person, size: 32, color: primaryColor),
      );
    }
    // 3. Varsayılan ikon
    return Icon(Icons.person, size: 32, color: primaryColor);
  }

  void _showPhotoSelectBS(BuildContext context, FoodProfileViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _BSOption(
                icon: Icons.camera_alt_rounded,
                title: LocaleKeys.common_pickFromCamera.tr(),
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              _BSOption(
                icon: Icons.photo_library_rounded,
                title: LocaleKeys.common_pickFromGallery.tr(),
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _BSOption extends StatelessWidget {
  const _BSOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1B1B),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: primaryColor),
    );
  }
}
