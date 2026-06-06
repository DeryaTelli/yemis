import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import '../common/card_date_picker_field.dart';
import 'food_reserve_bottom_sheet.dart';

/// Kart numarasını her 4 hanede bir boşluk koyarak formatlar.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    if (digitsOnly.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class FoodReservePaymentRow extends StatelessWidget {
  const FoodReservePaymentRow({super.key, required this.vm});

  final FoodReserveViewModel vm;

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FoodReserveBottomSheet(vm: vm),
    );
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
    if (vm.isNewCardMode ||
        (vm.savedCards.isEmpty && vm.selectedSavedCard == null)) {
      return _buildNewCardForm(context);
    } else if (vm.selectedSavedCard != null) {
      return _buildSavedCardSelectedView(context, vm.selectedSavedCard!);
    } else {
      return _buildUnselectedView(context);
    }
  }

  // State 1: Unselected View (Image 4)
  Widget _buildUnselectedView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showPaymentSheet(context),
            child: const Row(
              children: [
                Icon(Icons.add, size: 18, color: Color(0xFFF58220)),
                SizedBox(width: 4),
                Text(
                  'Select a Payment Method',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF58220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // State 2: Saved Card Selected View (Image 1)
  Widget _buildSavedCardSelectedView(BuildContext context, SavedCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kart Bilgileri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              GestureDetector(
                onTap: () => vm.toggleNewCardMode(true),
                child: const Text(
                  'Yeni Kart Kullan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF58220),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showPaymentSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryBorderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${card.cardName} - ${card.lastFour}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ),
                  _buildBankLogo(card.bankName),
                  const SizedBox(width: 8),
                  _buildCardTypeLogo(card.cardType),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF495057),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // State 3: New Card Form View (Image 3)
  Widget _buildNewCardForm(BuildContext context) {
    final List<String> months = [
      'Ay',
      ...List.generate(12, (index) => (index + 1).toString().padLeft(2, '0')),
    ];
    final List<String> years = [
      'Yıl',
      ...List.generate(15, (index) => (DateTime.now().year + index).toString()),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kart Bilgileri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              if (vm.savedCards.isNotEmpty)
                GestureDetector(
                  onTap: () => vm.toggleNewCardMode(false),
                  child: const Row(
                    children: [
                      Text(
                        'Kayıtlı Kartımla Öde',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF58220),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.credit_card_rounded,
                        size: 16,
                        color: Color(0xFFF58220),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Kart No Field
          const Text(
            'Kart No',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBorderColor),
            ),
            child: TextField(
              controller: vm.cardNoController,
              keyboardType: TextInputType.number,
              inputFormatters: [_CardNumberFormatter()],
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0000 0000 0000 0000',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryTextColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Son Kullanma Tarihi Dropdowns
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Son Kullanma Tarihi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: CardDatePickerField(
                            hint: 'Ay',
                            value: vm.selectedExpiryMonth,
                            items: months,
                            compact: true,
                            borderColor: AppColors.primaryBorderColor,
                            onChanged: vm.setExpiryMonth,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CardDatePickerField(
                            hint: 'Yıl',
                            value: vm.selectedExpiryYear,
                            items: years,
                            compact: true,
                            borderColor: AppColors.primaryBorderColor,
                            onChanged: vm.setExpiryYear,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // CVV Input
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('CVV Nedir?'),
                                content: const Text(
                                  'CVV, kartınızın arkasında bulunan 3 haneli güvenlik kodudur.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text(
                                      'Kapat',
                                      style: TextStyle(
                                        color: Color(0xFFF58220),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF58220),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF58220),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryBorderColor),
                      ),
                      child: TextField(
                        controller: vm.cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Secure Checkbox
          GestureDetector(
            onTap: () => vm.set3dSecure(!vm.use3dSecure),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: vm.use3dSecure,
                    activeColor: const Color(0xFFF58220),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      if (val != null) vm.set3dSecure(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '3D Secure ile ödemek istiyorum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
