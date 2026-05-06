import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../utils/constants/app_colors.dart';
import '../../models/app_module_type.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../viewmodels/business/business_profile_viewmodel.dart';

class BusinessProfileEditView extends StatelessWidget {
  const BusinessProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BusinessProfileEditBody();
  }
}

class _BusinessProfileEditBody extends StatefulWidget {
  const _BusinessProfileEditBody();

  @override
  State<_BusinessProfileEditBody> createState() =>
      _BusinessProfileEditBodyState();
}

class _BusinessProfileEditBodyState extends State<_BusinessProfileEditBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProfileViewModel>().fetchProfile();
    });
  }

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(###) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessProfileViewModel>();
    final primaryColor = Theme.of(context).primaryColor;

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.business,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(LocaleKeys.businessProfile_editTitle.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // ─── Profil Fotoğrafı (Logo) ──────────────────────
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
                labelText: 'Ad Soyad',
                hintText: 'Adınızı ve soyadınızı girin',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: vm.emailController,
                labelText: 'E-posta',
                hintText: 'E-posta adresinizi girin',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: vm.phoneController,
                labelText: 'Telefon Numarası',
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
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () => vm.updateAccount(context),
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
                    child: const Text(
                      'Profilini Güncelle',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
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
                  child: const Text(
                    'Hesabı Sil',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BusinessProfileViewModel vm, Color primaryColor) {
    if (vm.selectedImageFile != null) {
      return Image.file(
        vm.selectedImageFile!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
    if (vm.imageUrl != null && vm.imageUrl!.isNotEmpty) {
      return Image.network(
        vm.imageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.store_rounded, size: 32, color: primaryColor),
      );
    }
    return Icon(Icons.store_rounded, size: 32, color: primaryColor);
  }

  void _showPhotoSelectBS(BuildContext context, BusinessProfileViewModel vm) {
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
                title: 'Kamera ile Çek',
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              _BSOption(
                icon: Icons.photo_library_rounded,
                title: 'Galeriden Seç',
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
