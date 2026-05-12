import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../utils/locale_keys.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/reset_password_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/otp_box.dart';

import '../../widgets/common/success_dialog_custom.dart';
import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late ResetPasswordViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<ResetPasswordViewModel>();
  }

  @override
  void dispose() {
    _viewModel.clearFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordViewModel>(
      builder: (context, vm, _) {
        return LoadingOverlay(
          isLoading: vm.isLoading,
          moduleType: AppModuleType.food,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: Text(LocaleKeys.auth_resetPassword_title.tr()),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Lottie.asset(
                          'assets/lottie/forgot_password.json',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hesabınız için yeni bir şifre belirleyin.',
                        style: CustomTextStyles.regular16Grey,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Yeni Şifre
                      CustomTextField(
                        controller: vm.passwordController,
                        hintText: LocaleKeys.auth_fields_newPassword.tr(),
                        obscureText: !vm.passwordVisible,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            vm.passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF838383),
                          ),
                          onPressed: vm.togglePasswordVisibility,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return LocaleKeys.auth_validation_passwordEmpty
                                .tr();
                          }
                          if (v.length < 8 || !v.contains(RegExp(r'[A-Z]'))) {
                            return LocaleKeys.auth_validation_passwordMinLength
                                .tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Şifre Tekrar
                      CustomTextField(
                        controller: vm.confirmPasswordController,
                        hintText: LocaleKeys.auth_fields_confirmPassword.tr(),
                        obscureText: !vm.passwordVisible,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          icon: Icon(
                            vm.passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF838383),
                          ),
                          onPressed: vm.togglePasswordVisibility,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return LocaleKeys.auth_validation_passwordEmpty
                                .tr();
                          }
                          if (v != vm.passwordController.text) {
                            return LocaleKeys.auth_validation_passwordsNotMatch
                                .tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Hata mesajı
                      CustomButton(
                        text: LocaleKeys.auth_forgotPassword_button.tr(),
                        onPressed: () => vm.resetPassword(
                          formKey: _formKey,
                          onSuccess: () {
                            vm.clearFields();
                            SuccessDialogCustom.show(
                              context,
                              message: LocaleKeys.auth_forgotPassword_success
                                  .tr(),
                              onConfirm: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                            );
                          },
                          onError: (msg) {
                            ErrorDialogCustom.show(context, message: msg);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
