import 'package:flutter/material.dart';

import '../../models/auth/saved_card_model.dart';
import '../../services/auth/i_auth_service.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({required IAuthService authService})
    : _authService = authService;

  final IAuthService _authService;

  List<SavedCardModel> _cards = [];
  List<SavedCardModel> get cards => List.unmodifiable(_cards);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCards() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _authService.getCards();
      _cards = (result ?? []).map(SavedCardModel.fromJson).toList();
    } catch (_) {
      _errorMessage = 'Kartlar yüklenirken bir hata oluştu.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCard({
    required String cardName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required bool isDefault,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final number = cardNumber.replaceAll(RegExp(r'\D'), '');
      final cardType = number.startsWith('5') ? 'MasterCard' : 'VISA';
      final masked =
          '${number.substring(0, 6)}******${number.substring(number.length - 4)}';
      final result = await _authService.addCard({
        'card_holder_name': cardName.trim(),
        'card_number_masked': masked,
        'expiry_date': '$expiryMonth/${expiryYear.substring(2)}',
        'card_type': cardType,
        'is_default': isDefault,
      });
      if (!result.success) {
        _errorMessage = result.message;
        return false;
      }
      await fetchCards();
      return true;
    } catch (_) {
      _errorMessage = 'Kart kaydedilirken bir hata oluştu.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCard(int cardId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _authService.deleteCard(cardId);
      if (!result.success) {
        _errorMessage = result.message;
        return false;
      }
      _cards.removeWhere((card) => card.id == cardId);
      return true;
    } catch (_) {
      _errorMessage = 'Kart silinirken bir hata oluştu.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
