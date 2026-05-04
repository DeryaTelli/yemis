import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:yemis/widgets/common/error_dialog_custom.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  late LoginViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<LoginViewModel>();
  }

  @override
  void dispose() {
    _viewModel.clearFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return LoadingOverlay(
          isLoading: vm.isLoading,
          moduleType: AppModuleType.food,
          child: Scaffold(
            appBar: AppBar(
              title: Text(LocaleKeys.auth_login_title.tr()),
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
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
                          'assets/lottie/login_register.json',
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),

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
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Remember me + Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: vm.toggleRememberMe,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: vm.rememberMe,
                                  onChanged: (_) => vm.toggleRememberMe(),
                                  activeColor: const Color(0xFFFE8800),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                Text(
                                  LocaleKeys.auth_login_rememberMe.tr(),
                                  style: CustomTextStyles.regular14Black,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () {
                                vm.clearFields();
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
                              child: Text(
                                LocaleKeys.auth_login_forgotPassword.tr(),
                                style: CustomTextStyles.regular14Primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      CustomButton(
                        text: LocaleKeys.auth_login_button.tr(),
                        onPressed: () => vm.login(
                          formKey: _formKey,
                          onSuccess: () async {
                            final route = await vm.afterLoginRoute();
                            if (!context.mounted) return;
                            vm.clearFields();
                            Navigator.pushReplacementNamed(context, route);
                          },
                          onError: (msg) {
                            ErrorDialogCustom.show(context, message: msg);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.auth_login_noAccount.tr(),
                            style: CustomTextStyles.regular14Grey,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              vm.clearFields();
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: Text(
                              LocaleKeys.auth_login_register.tr(),
                              style: CustomTextStyles.bold14Primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
