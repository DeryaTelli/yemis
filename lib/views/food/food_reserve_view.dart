import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import '../../views/food/food_order_success_view.dart';
import '../../widgets/food/food_reserve_info_card.dart';
import '../../widgets/food/food_reserve_payment_row.dart';
import '../../widgets/food/food_reserve_price_row.dart';
import '../../widgets/food/food_reserve_quantity_row.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/food/i_food_service.dart';

/// Rezervasyon onay ve ödeme yöntemi seçim ekranı.
class FoodReserveView extends StatelessWidget {
  const FoodReserveView({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => FoodReserveViewModel(
        listing: listing,
        authService: ctx.read<IAuthService>(),
        foodService: ctx.read<IFoodService>(),
      ),
      child: const _FoodReserveBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────
class _FoodReserveBody extends StatelessWidget {
  const _FoodReserveBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodReserveViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(LocaleKeys.foodReserve_title.tr())),
      body: Column(
        children: [
          // ── Scrollable içerik ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restoran bilgisi
                  Center(
                    child: FoodReserveInfoCard(
                      listing: vm.listing,
                      deliveryText: vm.deliveryText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Ödeme Yöntemi
                  FoodReservePaymentRow(vm: vm),
                  const SizedBox(height: 28),

                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),

                  // Adet
                  FoodReserveQuantityRow(vm: vm),
                  const SizedBox(height: 20),

                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),

                  // Fiyat
                  FoodReservePriceRow(vm: vm),
                ],
              ),
            ),
          ),

          // ── Alt Rezerve Butonu ───────────────────────────
          _ReserveButton(vm: vm),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Alt buton
// ─────────────────────────────────────────────────────────────
class _ReserveButton extends StatelessWidget {
  const _ReserveButton({required this.vm});

  final FoodReserveViewModel vm;

  Future<void> _onReserve(BuildContext context) async {
    final success = await vm.reserve();

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rezervasyon sırasında bir hata oluştu. Lütfen tekrar deneyin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = context.read<IAuthService>();
    final pendingCardData = vm.shouldOfferCardSave ? vm.pendingCardData : null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FoodOrderSuccessView(
          authService: authService,
          pendingCardData: pendingCardData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 16),
      color: Colors.white,
      child: GestureDetector(
        onTap: vm.isLoading ? null : () => _onReserve(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: vm.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  LocaleKeys.foodReserve_reserveButton.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
