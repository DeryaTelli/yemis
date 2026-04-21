import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/forgot_password_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_banner.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late ForgotPasswordViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<ForgotPasswordViewModel>();
  }

  @override
  void dispose() {
    _viewModel.clearFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.auth_forgotPassword_title.tr())),
      body: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Lottie.asset(
                        'assets/lottie/forgot_password.json',
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      LocaleKeys.auth_forgotPassword_description.tr(),
                      style: CustomTextStyles.regular14Grey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (vm.errorKey != null) ...[
                      ErrorBanner(
                        message: vm.errorKey!.tr(),
                        onDismiss: vm.clearError,
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      controller: vm.emailController,
                      hintText: LocaleKeys.auth_fields_email.tr(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return LocaleKeys.auth_validation_emailEmpty.tr();
                        }
                        if (!v.contains('@')) {
                          return LocaleKeys.auth_validation_emailInvalid.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: LocaleKeys.auth_forgotPassword_button.tr(),
                      isLoading: vm.isLoading,
                      onPressed: () => vm.sendResetEmail(
                        formKey: _formKey,
                        onSuccess: (email) {
                          vm.clearFields();
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.verification,
                            arguments: {'email': email, 'isPasswordReset': true},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
