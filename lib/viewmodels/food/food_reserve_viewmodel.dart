import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/food/i_food_service.dart';

class SavedCard {
  final String id;
  final String cardName;
  final String bankName;
  final String cardNumber; // e.g., "523529******0082"
  final String lastFour; // "0082"
  final String cardType; // "VISA" or "MasterCard"
  final bool isFavorite;

  SavedCard({
    required this.id,
    required this.cardName,
    required this.bankName,
    required this.cardNumber,
    required this.lastFour,
    required this.cardType,
    this.isFavorite = false,
  });
}

/// Rezervasyon onay & ödeme seçimi ViewModel'i.
class FoodReserveViewModel extends ChangeNotifier {
  FoodReserveViewModel({
    required FoodListing listing,
    required IAuthService authService,
    required IFoodService foodService,
  }) : _listing = listing,
       _authService = authService,
       _foodService = foodService {
    cardNoController = TextEditingController();
    cvvController = TextEditingController();
    Future.microtask(() async {
      await Future.wait([loadCards(), _refreshListingDetails()]);
    });
  }

  FoodListing _listing;
  FoodListing get listing => _listing;
  final IAuthService _authService;
  final IFoodService _foodService;

  // ─── Controllers & Form State ──────────────────────────
  late final TextEditingController cardNoController;
  late final TextEditingController cvvController;
  String selectedExpiryMonth = 'Ay';
  String selectedExpiryYear = 'Yıl';
  bool use3dSecure = false;

  // ─── State ──────────────────────────────────────────────
  int _quantity = 1;
  int get quantity => _quantity;

  String? _quantityError;
  String? get quantityError => _quantityError;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNewCardMode = false;
  bool get isNewCardMode => _isNewCardMode;

  SavedCard? _selectedSavedCard;
  SavedCard? get selectedSavedCard => _selectedSavedCard;

  final List<SavedCard> _savedCards = [];
  List<SavedCard> get savedCards => _savedCards;

  // Rezervasyon sonrası kart kaydetme için bekleyen kart verisi
  Map<String, dynamic>? _pendingCardData;
  bool _lastReserveWasNewCard = false;

  /// True ise rezervasyon sonrası kart kaydetme dialogu gösterilmeli.
  bool get lastReserveWasNewCard => _lastReserveWasNewCard;

  // ─── Computed ────────────────────────────────────────────
  double get totalPrice => listing.price * _quantity;

  String get totalPriceText => '${totalPrice.toInt()} TL';

  String get deliveryText {
    if (listing.deliveryStartTime == null) return listing.timeRange;
    final now = DateTime.now();
    final start = listing.deliveryStartTime!;
    final isToday =
        now.year == start.year &&
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
  Future<void> _refreshListingDetails() async {
    try {
      _listing = await _foodService.getFoodDetail(_listing.id);
      final availableQuantity = _listing.availableQuantity;
      if (availableQuantity != null && _quantity > availableQuantity) {
        _quantityError = 'İlan sayısını geçemezsiniz.';
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Load listing detail error: $e');
    }
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cardsData = await _authService.getCards();
      if (cardsData != null) {
        _savedCards.clear();
        for (final item in cardsData) {
          final maskedNum = item['card_number_masked'] ?? '';
          _savedCards.add(
            SavedCard(
              id: (item['id'] ?? '').toString(),
              cardName: item['card_holder_name'] ?? 'Kayıtlı Kartım',
              bankName: _inferBankName(maskedNum),
              cardNumber: maskedNum,
              lastFour: _getLastFour(maskedNum),
              cardType: item['card_type'] ?? 'VISA',
              isFavorite: item['is_default'] ?? false,
            ),
          );
        }

        // Select the favorite card or default to first/null
        if (_savedCards.isNotEmpty) {
          final favIndex = _savedCards.indexWhere((c) => c.isFavorite);
          _selectedSavedCard = favIndex != -1
              ? _savedCards[favIndex]
              : _savedCards.first;
          _isNewCardMode = false;
        } else {
          _selectedSavedCard = null;
          _isNewCardMode = true; // Kart yoksa yeni kart formuna geç
        }
      }
    } catch (e) {
      debugPrint('Load cards error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _inferBankName(String cardNumber) {
    if (cardNumber.startsWith('523529') ||
        cardNumber.startsWith('434528') ||
        cardNumber.startsWith('476619')) {
      return 'Ziraat Bankası';
    } else if (cardNumber.startsWith('403998')) {
      return 'İş Bankası';
    }
    return 'Ziraat Bankası';
  }

  String _getLastFour(String maskedNumber) {
    if (maskedNumber.length >= 4) {
      return maskedNumber.substring(maskedNumber.length - 4);
    }
    return '0000';
  }

  void increment() {
    final availableQuantity = listing.availableQuantity;
    if (availableQuantity != null && _quantity >= availableQuantity) {
      _quantityError = 'İlan sayısını geçemezsiniz.';
      notifyListeners();
      return;
    }

    _quantity++;
    _quantityError = null;
    notifyListeners();
  }

  void decrement() {
    if (_quantity <= 1) return;
    _quantity--;
    _quantityError = null;
    notifyListeners();
  }

  void selectSavedCard(SavedCard? card) {
    _selectedSavedCard = card;
    _isNewCardMode = false;
    notifyListeners();
  }

  void toggleNewCardMode(bool active) {
    _isNewCardMode = active;
    if (active) {
      _selectedSavedCard = null;
    }
    notifyListeners();
  }

  void set3dSecure(bool val) {
    use3dSecure = val;
    notifyListeners();
  }

  void setExpiryMonth(String val) {
    selectedExpiryMonth = val;
    notifyListeners();
  }

  void setExpiryYear(String val) {
    selectedExpiryYear = val;
    notifyListeners();
  }

  /// Yeni kartı API'ye kaydeder (kullanıcı onayladıktan sonra).
  Future<bool> saveCardIfPending() async {
    if (_pendingCardData == null) return false;
    try {
      final res = await _authService.addCard(_pendingCardData!);
      _pendingCardData = null;
      if (res.success) await loadCards();
      return res.success;
    } catch (e) {
      debugPrint('Save card error: $e');
      _pendingCardData = null;
      return false;
    }
  }

  /// Rezervasyonu tamamlar — önce sipariş API'sini çağırır.
  Future<bool> reserve() async {
    await _refreshListingDetails();

    final availableQuantity = listing.availableQuantity;
    if (availableQuantity != null && _quantity > availableQuantity) {
      _quantityError = 'İlan sayısını geçemezsiniz.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _lastReserveWasNewCard = false;
    _pendingCardData = null;
    notifyListeners();

    // Yeni kart moddaysa kart bilgilerini hazırla ama henüz kaydetme
    if (_isNewCardMode) {
      final cardNo = cardNoController.text.replaceAll(' ', '').trim();
      if (cardNo.length < 16) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final cardType = cardNo.startsWith('5') ? 'MasterCard' : 'VISA';
      final maskedCardNo =
          '${cardNo.substring(0, 6)}******${cardNo.substring(cardNo.length - 4)}';
      final expMonth = selectedExpiryMonth == 'Ay' ? '12' : selectedExpiryMonth;
      final expYear = selectedExpiryYear == 'Yıl'
          ? '30'
          : selectedExpiryYear.substring(selectedExpiryYear.length - 2);
      final expiry = '$expMonth/$expYear';

      _pendingCardData = {
        'card_holder_name': cardType == 'MasterCard'
            ? 'BANKKART COMBO kartım'
            : 'BANKKART kartım',
        'card_number_masked': maskedCardNo,
        'expiry_date': expiry,
        'card_type': cardType,
        'is_default': false,
      };
      _lastReserveWasNewCard = true;
    }

    // POST /api/orders çağrısı
    try {
      final bagId = int.tryParse(listing.id) ?? 0;
      final success = await _foodService.createOrder(bagId, _quantity);

      _isLoading = false;
      notifyListeners();

      if (!success) {
        _pendingCardData = null;
        _lastReserveWasNewCard = false;
      }

      return success;
    } catch (e) {
      debugPrint('Reserve error: $e');
      _pendingCardData = null;
      _lastReserveWasNewCard = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    cardNoController.dispose();
    cvvController.dispose();
    super.dispose();
  }
}
