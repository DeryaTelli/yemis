import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodReserveBottomSheet extends StatefulWidget {
  const FoodReserveBottomSheet({super.key, required this.vm});

  final FoodReserveViewModel vm;

  @override
  State<FoodReserveBottomSheet> createState() => _FoodReserveBottomSheetState();
}

class _FoodReserveBottomSheetState extends State<FoodReserveBottomSheet> {
  SavedCard? _tempSelectedCard;
  bool _tempNewCardSelected = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedCard = widget.vm.selectedSavedCard;
    _tempNewCardSelected = widget.vm.isNewCardMode;

    // Seçili kart yoksa ve kayıtlı kart varsa ilk kartı seç
    if (_tempSelectedCard == null &&
        !_tempNewCardSelected &&
        widget.vm.savedCards.isNotEmpty) {
      _tempSelectedCard = widget.vm.savedCards.first;
    }
  }

  Widget _buildBankLogo(String bankName) {
    if (bankName == 'Ziraat Bankası') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Color(0xFFE30613),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grain_rounded,
                size: 8,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Ziraat Bankası',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 6.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (bankName == 'İş Bankası') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Color(0xFF003087),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                size: 8,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'İş Bankası',
              style: TextStyle(
                color: Color(0xFF003087),
                fontSize: 6.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const Icon(Icons.credit_card_rounded, size: 14);
  }

  Widget _buildCardTypeLogo(String cardType) {
    if (cardType == 'MasterCard') {
      return SizedBox(
        width: 26,
        height: 16,
        child: Stack(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFEB0015),
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              left: 8,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (cardType == 'VISA') {
      return const Text(
        'VISA',
        style: TextStyle(
          color: Color(0xFF1A1F71),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Kayıtlı Kartlarım',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),

            // Card List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...widget.vm.savedCards.map((card) {
                      final bool isSelected =
                          !_tempNewCardSelected &&
                          (_tempSelectedCard?.id == card.id);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _tempSelectedCard = card;
                            _tempNewCardSelected = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFF58220)
                                  : const Color(0xFFE5E5E5),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Radio Icon
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? const Color(0xFFF58220)
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              // Bank Logo
                              _buildBankLogo(card.bankName),
                              const SizedBox(width: 12),
                              // Card Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.cardName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildCardTypeLogo(card.cardType),
                                        const SizedBox(width: 6),
                                        Text(
                                          card.cardNumber,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Başka Kartla Öde option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempNewCardSelected = true;
                          _tempSelectedCard = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _tempNewCardSelected
                                ? const Color(0xFFF58220)
                                : const Color(0xFFE5E5E5),
                            width: _tempNewCardSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _tempNewCardSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: _tempNewCardSelected
                                  ? const Color(0xFFF58220)
                                  : Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Başka Kartla Öde',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Select Card Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_tempNewCardSelected) {
                      widget.vm.toggleNewCardMode(true);
                    } else {
                      widget.vm.selectSavedCard(_tempSelectedCard);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF58220),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kartı Seç',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
