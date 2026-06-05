import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import '../../views/food/food_reservation_confirm_view.dart';
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
      child: _FoodReserveBody(listing: listing),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────
class _FoodReserveBody extends StatelessWidget {
  const _FoodReserveBody({required this.listing});

  final FoodListing listing;

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
                      listing: listing,
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
          _ReserveButton(vm: vm, listing: listing),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Alt buton
// ─────────────────────────────────────────────────────────────
class _ReserveButton extends StatelessWidget {
  const _ReserveButton({required this.vm, required this.listing});

  final FoodReserveViewModel vm;
  final FoodListing listing;

  Future<void> _onReserve(BuildContext context) async {
    final success = await vm.reserve();

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon sırasında bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Yeni kart girilmişse kayıt dialog'u göster
    if (vm.lastReserveWasNewCard) {
      final shouldSave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Siparişiniz Rezerve Edildi!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: const Text(
            'Kartınızı kayıt etmek ister misiniz?\nBöylece bir sonraki siparişinizde kolayca kullanabilirsiniz.',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Hayır',
                style: TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF58220),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Kayıt Et',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

      if (shouldSave == true && context.mounted) {
        await vm.saveCardIfPending();
      }
    }

    if (!context.mounted) return;

    // Onay ekranına yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FoodReservationConfirmView(
          listing: listing,
          quantity: vm.quantity,
          totalPrice: vm.totalPrice,
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
