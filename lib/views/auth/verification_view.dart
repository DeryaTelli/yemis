import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/verification_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/otp_box.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.auth_verification_title.tr()),
      ),
      body: Consumer<VerificationViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  Text(
                    LocaleKeys.auth_verification_description.tr(),
                    style: CustomTextStyles.regular14Grey,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // 4 haneli OTP input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: OtpBox(
                          controller: vm.codeControllers[index],
                          focusNode: vm.focusNodes[index],
                          onChanged: (v) =>
                              vm.onCodeChanged(index, v, context),
                          onBackspace: () =>
                              vm.onCodeBackspace(index, context),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Hata mesajı
                  if (vm.errorKey != null) ...[
                    Text(
                      vm.errorKey!.tr(),
                      style: CustomTextStyles.regular14Black
                          .copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    LocaleKeys.auth_verification_codeSent.tr(),
                    style: CustomTextStyles.regular14Grey,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Timer veya Tekrar gönder
                  Center(
                    child: vm.canResend
                        ? GestureDetector(
                            onTap: vm.isLoading ? null : vm.resendCode,
                            child: Text(
                              LocaleKeys.auth_verification_resend.tr(),
                              style: CustomTextStyles.bold14Primary,
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                vm.timerDisplay,
                                style: CustomTextStyles.extraBold20DarkGrey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LocaleKeys.auth_verification_resend.tr(),
                                style: CustomTextStyles.regular14Grey,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),

                  CustomButton(
                    text: LocaleKeys.auth_verification_button.tr(),
                    isLoading: vm.isLoading,
                    onPressed: () => vm.verify(
                      onSuccess: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
