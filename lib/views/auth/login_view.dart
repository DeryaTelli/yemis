import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_banner.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.auth_login_title.tr()),
      ),
      body: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    if (vm.errorKey != null) ...[
                      ErrorBanner(
                        message: vm.errorKey!.tr(),
                        onDismiss: vm.clearError,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email
                    CustomTextField(
                      controller: vm.emailController,
                      hintText: LocaleKeys.auth_fields_email.tr(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 12),

                    // Şifre
                    CustomTextField(
                      controller: vm.passwordController,
                      hintText: LocaleKeys.auth_fields_password.tr(),
                      obscureText: !vm.passwordVisible,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF838383),
                        ),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return LocaleKeys.auth_validation_passwordEmpty.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Remember me + Forgot password
                    Row(
                      children: [
                        GestureDetector(
                          onTap: vm.toggleRememberMe,
                          child: Row(
                            children: [
                              Checkbox(
                                value: vm.rememberMe,
                                onChanged: (_) => vm.toggleRememberMe(),
                                activeColor: const Color(0xFFFE8800),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(LocaleKeys.auth_login_rememberMe.tr(),
                                  style: CustomTextStyles.regular14Black),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.forgotPassword),
                          child: Text(
                            LocaleKeys.auth_login_forgotPassword.tr(),
                            style: CustomTextStyles.regular14Grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: LocaleKeys.auth_login_button.tr(),
                      isLoading: vm.isLoading,
                      onPressed: () => vm.login(
                        formKey: _formKey,
                        onSuccess: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.home),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(LocaleKeys.auth_login_noAccount.tr(),
                            style: CustomTextStyles.regular14Grey),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.register),
                          child: Text(LocaleKeys.auth_login_register.tr(),
                              style: CustomTextStyles.bold14Primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
