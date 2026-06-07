import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../services/auth/i_auth_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';

class FoodOrderSuccessView extends StatefulWidget {
  const FoodOrderSuccessView({
    super.key,
    required this.authService,
    this.pendingCardData,
  });

  final IAuthService authService;
  final Map<String, dynamic>? pendingCardData;

  @override
  State<FoodOrderSuccessView> createState() => _FoodOrderSuccessViewState();
}

class _FoodOrderSuccessViewState extends State<FoodOrderSuccessView> {
  bool _isSaving = false;

  bool get _shouldOfferCardSave => widget.pendingCardData != null;

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.foodHome,
      (route) => false,
    );
  }

  Future<void> _saveCardAndGoHome() async {
    final cardData = widget.pendingCardData;
    if (cardData == null || _isSaving) return;

    setState(() => _isSaving = true);
    final response = await widget.authService.addCard(cardData);
    if (!mounted) return;

    if (!response.success) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
      return;
    }

    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.16),
                        AppColors.primaryColor.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.65, 1],
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 210,
                      height: 210,
                      child: Transform.scale(
                        scale: 1.2,
                        child: Lottie.asset(
                          'assets/lottie/success.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Siparişiniz Başarıyla Rezerve Edildi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _shouldOfferCardSave
                      ? 'Kartınızı kaydetmek istiyor musunuz? Böylece sonraki siparişinizde kolayca kullanabilirsiniz.'
                      : 'Rezervasyon detaylarınızı ana sayfadan takip edebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.hintTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                if (_shouldOfferCardSave) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _LinearButton(
                          label: 'Hayır',
                          onPressed: _isSaving ? null : _goHome,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.08),
                              AppColors.primaryColor.withValues(alpha: 0.2),
                            ],
                          ),
                          foregroundColor: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LinearButton(
                          label: 'Kartı Kaydet',
                          onPressed: _isSaving ? null : _saveCardAndGoHome,
                          gradient: AppColors.primaryButtonGradient,
                          isLoading: _isSaving,
                        ),
                      ),
                    ],
                  ),
                ] else
                  _LinearButton(
                    label: 'Ana Sayfaya Dön',
                    onPressed: _goHome,
                    gradient: AppColors.primaryButtonGradient,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinearButton extends StatelessWidget {
  const _LinearButton({
    required this.label,
    required this.onPressed,
    required this.gradient,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: foregroundColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
