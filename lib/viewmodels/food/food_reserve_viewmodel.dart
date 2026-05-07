import 'package:flutter/foundation.dart';
import '../../models/food/food_listing.dart';
import '../../utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// Ödeme yöntemi seçenekleri.
enum PaymentMethod {
  googlePay,
  applePay,
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.googlePay:
        return LocaleKeys.foodReserve_googlePay.tr();
      case PaymentMethod.applePay:
        return LocaleKeys.foodReserve_applePay.tr();
    }
  }
}

/// Rezervasyon onay & ödeme seçimi ViewModel'i.
class FoodReserveViewModel extends ChangeNotifier {
  FoodReserveViewModel({required this.listing});

  final FoodListing listing;

  // ─── State ──────────────────────────────────────────────

  int _quantity = 1;
  int get quantity => _quantity;

  PaymentMethod? _selectedPayment;
  PaymentMethod? get selectedPayment => _selectedPayment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Computed ────────────────────────────────────────────

  double get totalPrice => listing.price * _quantity;

  String get totalPriceText => '${totalPrice.toInt()} TL';

  String get deliveryText {
    if (listing.deliveryStartTime == null) return listing.timeRange;
    final now = DateTime.now();
    final start = listing.deliveryStartTime!;
    final isToday = now.year == start.year &&
        now.month == start.month &&
        now.day == start.day;
    if (isToday) {
      return '${LocaleKeys.common_pickupToday.tr()}  ${listing.timeRange}';
    } else {
      final months = [
        '',
        LocaleKeys.foodReservationConfirm_months_jan.tr(),
        LocaleKeys.foodReservationConfirm_months_feb.tr(),
        LocaleKeys.foodReservationConfirm_months_mar.tr(),
        LocaleKeys.foodReservationConfirm_months_apr.tr(),
        LocaleKeys.foodReservationConfirm_months_may.tr(),
        LocaleKeys.foodReservationConfirm_months_jun.tr(),
        LocaleKeys.foodReservationConfirm_months_jul.tr(),
        LocaleKeys.foodReservationConfirm_months_aug.tr(),
        LocaleKeys.foodReservationConfirm_months_sep.tr(),
        LocaleKeys.foodReservationConfirm_months_oct.tr(),
        LocaleKeys.foodReservationConfirm_months_nov.tr(),
        LocaleKeys.foodReservationConfirm_months_dec.tr(),
      ];
      return '${start.day} ${months[start.month]}  ${listing.timeRange}';
    }
  }

  // ─── Actions ─────────────────────────────────────────────

  void increment() {
    _quantity++;
    notifyListeners();
  }

  void decrement() {
    if (_quantity <= 1) return;
    _quantity--;
    notifyListeners();
  }

  void selectPayment(PaymentMethod method) {
    _selectedPayment = method;
    notifyListeners();
  }

  /// Rezervasyonu tamamlar. Gerçek backend entegrasyonunda API çağrısı yapılır.
  Future<bool> reserve() async {
    _isLoading = true;
    notifyListeners();

    // TODO: ApiService.createReservation(listing.id, quantity, selectedPayment)
    await Future<void>.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
