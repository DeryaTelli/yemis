import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/auth/change_password_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/success_dialog_custom.dart';

class ChangePasswordView extends StatelessWidget {
  final AppModuleType moduleType;
  const ChangePasswordView({super.key, this.moduleType = AppModuleType.food});

  @override
  Widget build(BuildContext context) {
    final section =
        (moduleType == AppModuleType.food ||
            moduleType == AppModuleType.business)
        ? AppSection.food
        : AppSection.volunteer;

    return Theme(
      data: AppTheme.themeFor(section),
      child: ChangeNotifierProvider(
        create: (_) =>
            ChangePasswordViewModel(authService: context.read<IAuthService>()),
        child: _Body(moduleType: moduleType),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final AppModuleType moduleType;
  const _Body({required this.moduleType});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();
    final themeColor =
        (widget.moduleType == AppModuleType.food ||
            widget.moduleType == AppModuleType.business)
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: widget.moduleType,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(LocaleKeys.auth_changePassword_title.tr()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/lottie/forgot_password.json',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hesap güvenliğiniz için mevcut şifrenizi doğrulamanız gerekmektedir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _oldPassController,
                labelText: 'Mevcut Şifre',
                hintText: '••••••••',
                obscureText: _obscureOld,
                onChanged: vm.onOldPasswordChanged,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _newPassController,
                labelText: 'Yeni Şifre',
                hintText: '••••••••',
                obscureText: _obscureNew,
                onChanged: vm.onNewPasswordChanged,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await vm.submit();
                    if (success && context.mounted) {
                      SuccessDialogCustom.show(
                        context,
                        message: 'Şifreniz başarıyla değiştirildi.',
                        onConfirm: () => Navigator.pop(context),
                      );
                    } else if (vm.errorMessage != null && context.mounted) {
                      ErrorDialogCustom.show(
                        context,
                        message: vm.errorMessage!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Şifreyi Güncelle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
