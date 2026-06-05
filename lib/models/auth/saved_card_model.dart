class SavedCardModel {
  const SavedCardModel({
    required this.id,
    required this.cardHolderName,
    required this.cardNumberMasked,
    required this.expiryDate,
    required this.cardType,
    required this.isDefault,
  });

  final int id;
  final String cardHolderName;
  final String cardNumberMasked;
  final String expiryDate;
  final String cardType;
  final bool isDefault;

  String get lastFour {
    final digits = cardNumberMasked.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  }

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      id: json['id'] as int? ?? 0,
      cardHolderName: json['card_holder_name'] as String? ?? 'Kayıtlı Kartım',
      cardNumberMasked: json['card_number_masked'] as String? ?? '',
      expiryDate: json['expiry_date'] as String? ?? '',
      cardType: json['card_type'] as String? ?? 'Kart',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
