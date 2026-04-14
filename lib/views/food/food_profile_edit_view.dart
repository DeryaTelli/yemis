import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_profile_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';

class FoodProfileEditView extends StatelessWidget {
  const FoodProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodProfileViewModel(),
      child: const _FoodProfileEditBody(),
    );
  }
}

class _FoodProfileEditBody extends StatefulWidget {
  const _FoodProfileEditBody();

  @override
  State<_FoodProfileEditBody> createState() => _FoodProfileEditBodyState();
}

class _FoodProfileEditBodyState extends State<_FoodProfileEditBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
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
                onTap: () => _showPhotoSelectBS(context),
                child: Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEADCC6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFFFE8800),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: Color(0xFFFE8800),
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
              controller: vm.nameController,
              labelText: 'Ad',
              hintText: 'Adınızı girin',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: vm.surnameController,
              labelText: 'Soyad',
              hintText: 'Soyadınızı girin',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: vm.emailController,
              labelText: 'E-posta',
              hintText: 'E-posta adresinizi girin',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),

            // ─── Aksiyon Butonları ─────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  vm.updateAccount();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Hesabı Düzenle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPhotoSelectBS(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                title: 'Take from Camera',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              _BSOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                onTap: () => Navigator.pop(context),
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1B1B),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.primaryColor,
      ),
    );
  }
}
