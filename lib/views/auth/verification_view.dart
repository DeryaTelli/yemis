import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/verification_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/otp_box.dart';

import '../../widgets/common/success_dialog_custom.dart';
import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  late VerificationViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<VerificationViewModel>();
  }

  @override
  void dispose() {
    _viewModel.clearFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationViewModel>(
      builder: (context, vm, _) {
        return LoadingOverlay(
          isLoading: vm.isLoading,
          moduleType: AppModuleType.food,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                toolbarHeight: 80,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (vm.isPasswordReset) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.register);
                    }
                  },
                ),
                title: Text(LocaleKeys.auth_verification_title.tr()),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/lottie/otp_verification.json',
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      vm.isPasswordReset
                          ? 'Şifrenizi yenilemek için doğrulama kodunu girin'
                          : LocaleKeys.auth_verification_description.tr(),
                      style: CustomTextStyles.semiBold16Grey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: OtpBox(
                            controller: vm.codeControllers[index],
                            focusNode: vm.focusNodes[index],
                            onChanged: (v) => vm.onCodeChanged(index, v, context),
                            onBackspace: () => vm.onCodeBackspace(index, context),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // Timer veya Tekrar gönder
                    Column(
                      children: [
                        if (!vm.canResend)
                          Text(
                            vm.timerDisplay,
                            style: CustomTextStyles.semiBold16Grey,
                          )
                        else
                          GestureDetector(
                            onTap: vm.isLoading
                                ? null
                                : () => vm.resendCode(
                                      onError: (msg) => ErrorDialogCustom.show(
                                          context,
                                          message: msg),
                                    ),
                            child: Text(
                              LocaleKeys.auth_verification_resend.tr(),
                              style: CustomTextStyles.extraBold16Primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomButton(
                      text: LocaleKeys.auth_verification_button.tr(),
                      onPressed: () => vm.verify(
                        onSuccess: (token) {
                          if (vm.isPasswordReset) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.resetPassword,
                              arguments: {
                                'email': vm.email,
                                'otp': token ?? vm.otp
                              },
                            );
                          } else {
                            vm.clearFields();
                            SuccessDialogCustom.show(
                              context,
                              message: LocaleKeys.auth_verification_successMessage.tr(),
                              onConfirm: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              },
                            );
                          }
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
        );
      },
    );
  }
}
