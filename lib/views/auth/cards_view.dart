import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';

import '../../models/app_module_type.dart';
import '../../models/auth/saved_card_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/auth/cards_viewmodel.dart';
import '../../widgets/common/card_date_picker_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/delete_confirmation_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';

class CardsView extends StatelessWidget {
  const CardsView({super.key, this.moduleType = AppModuleType.food});

  final AppModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    final section = moduleType == AppModuleType.volunteer
        ? AppSection.volunteer
        : AppSection.food;

    return ChangeNotifierProvider(
      create: (_) {
        final vm = CardsViewModel(authService: context.read<IAuthService>());
        Future.microtask(vm.fetchCards);
        return vm;
      },
      child: Theme(
        data: AppTheme.themeFor(section),
        child: _CardsBody(moduleType: moduleType),
      ),
    );
  }
}

class _CardsBody extends StatelessWidget {
  const _CardsBody({required this.moduleType});

  final AppModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CardsViewModel>();
    final themeColor = moduleType == AppModuleType.volunteer
        ? AppColors.volunteerColor
        : AppColors.primaryColor;

    return LoadingOverlay(
      isLoading: vm.isLoading && vm.cards.isNotEmpty,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('cards.title'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: vm.fetchCards,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ActionTile(
                icon: Icons.add,
                title: 'cards.addCard'.tr(),
                color: themeColor,
                onTap: () async {
                  final added = await Navigator.pushNamed(
                    context,
                    AppRoutes.addCard,
                    arguments: vm,
                  );
                  if (added == true && context.mounted) {
                    await vm.fetchCards();
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                'cards.myCards'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 10),
              if (vm.isLoading && vm.cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.cards.isEmpty)
                _EmptyCards(color: themeColor)
              else
                ...vm.cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SavedCardTile(
                      card: card,
                      onTap: () async {
                        final deleted = await Navigator.pushNamed(
                          context,
                          AppRoutes.cardDetail,
                          arguments: {'card': card, 'viewModel': vm},
                        );
                        if (deleted == true && context.mounted) {
                          await vm.fetchCards();
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCardView extends StatefulWidget {
  const AddCardView({super.key, required this.viewModel});

  final CardsViewModel viewModel;

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _cvvController = TextEditingController();
  String? _month;
  String? _year;
  bool _isDefault = false;

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      15,
      (index) => (DateTime.now().year + index).toString(),
    );

    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<CardsViewModel>(
        builder: (context, vm, _) => LoadingOverlay(
          isLoading: vm.isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('cards.addCard'.tr()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _InfoBanner(),
                  const SizedBox(height: 24),
                  _LabelledField(
                    label: 'cards.cardName'.tr(),
                    controller: _nameController,
                    hint: 'Kart İsmi',
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'cards.validation.cardName'.tr()
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _LabelledField(
                    label: 'cards.cardNumber'.tr(),
                    controller: _numberController,
                    hint: '0000 1111 2222 3333',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    validator: (value) =>
                        (value ?? '').replaceAll(' ', '').length == 16
                        ? null
                        : 'cards.validation.cardNumber'.tr(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('cards.expiryDate'.tr(), style: _labelStyle),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CardDatePickerField(
                                    hint: 'cards.month'.tr(),
                                    value: _month,
                                    items: List.generate(
                                      12,
                                      (i) => (i + 1).toString().padLeft(2, '0'),
                                    ),
                                    onChanged: (value) =>
                                        setState(() => _month = value),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CardDatePickerField(
                                    hint: 'cards.year'.tr(),
                                    value: _year,
                                    items: years,
                                    onChanged: (value) =>
                                        setState(() => _year = value),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 2,
                        child: _LabelledField(
                          label: 'cards.cvv'.tr(),
                          controller: _cvvController,
                          hint: '111',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (value) => (value ?? '').length == 3
                              ? null
                              : 'cards.validation.cvv'.tr(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    horizontalTitleGap: 0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                    controlAffinity: ListTileControlAffinity.leading,
                    visualDensity: VisualDensity.compact,
                    value: _isDefault,
                    activeColor: AppColors.primaryColor,
                    title: Text(
                      'cards.setDefault'.tr(),
                      style: CustomTextStyles.semiBold15DarkGrey,
                    ),
                    onChanged: (value) =>
                        setState(() => _isDefault = value ?? false),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'cards.saveCard'.tr(),
                    width: double.infinity,
                    height: 54,
                    borderRadius: 14,
                    onPressed: () => _save(context, vm),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, CardsViewModel vm) async {
    if (!_formKey.currentState!.validate() || _month == null || _year == null) {
      if (_month == null || _year == null) {
        _showMessage(context, 'cards.validation.expiryDate'.tr());
      }
      return;
    }
    final saved = await vm.addCard(
      cardName: _nameController.text,
      cardNumber: _numberController.text,
      expiryMonth: _month!,
      expiryYear: _year!,
      isDefault: _isDefault,
    );
    if (!context.mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      _showMessage(context, vm.errorMessage ?? 'cards.saveError'.tr());
    }
  }
}

class CardDetailView extends StatelessWidget {
  const CardDetailView({
    super.key,
    required this.card,
    required this.viewModel,
  });

  final SavedCardModel card;
  final CardsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CardsViewModel>(
        builder: (context, vm, _) => LoadingOverlay(
          isLoading: vm.isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('cards.detailTitle'.tr()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SavedCardTile(card: card, onTap: null),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _whiteBox,
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'cards.cardName'.tr(),
                        value: card.cardHolderName,
                      ),
                      _DetailRow(
                        label: 'cards.cardNumber'.tr(),
                        value: card.cardNumberMasked,
                      ),
                      _DetailRow(
                        label: 'cards.expiryDate'.tr(),
                        value: card.expiryDate,
                      ),
                      _DetailRow(
                        label: 'cards.cardType'.tr(),
                        value: card.cardType,
                      ),
                      _DetailRow(
                        label: 'cards.defaultCard'.tr(),
                        value: card.isDefault
                            ? 'common.yes'.tr()
                            : 'common.no'.tr(),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'cards.deleteCard'.tr(),
                  isOutlined: true,
                  backgroundColor: Colors.redAccent,
                  width: double.infinity,
                  height: 54,
                  borderRadius: 14,
                  onPressed: () => _confirmDelete(context, vm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CardsViewModel vm) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'cards.deleteCard'.tr(),
      message: 'cards.deleteConfirm'.tr(
        namedArgs: {'name': card.cardHolderName},
      ),
    );
    if (!confirmed || !context.mounted) return;
    final deleted = await vm.deleteCard(card.id);
    if (!context.mounted) return;
    if (deleted) {
      Navigator.pop(context, true);
    } else {
      _showMessage(context, vm.errorMessage ?? 'cards.deleteError'.tr());
    }
  }
}

const _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

final _whiteBox = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: const Color(0xFFE8E8E8)),
);

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({required this.card, required this.onTap});

  final SavedCardModel card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8E8E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.cardHolderName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
              const Divider(height: 22),
              Row(
                children: [
                  _CardTypeBadge(type: card.cardType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card.cardNumberMasked,
                      style: const TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTypeBadge extends StatelessWidget {
  const _CardTypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final isVisa = type.toUpperCase().contains('VISA');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVisa ? const Color(0xFF142787) : const Color(0xFF202020),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isVisa ? 'VISA' : 'MC',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _EmptyCards extends StatelessWidget {
  const _EmptyCards({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 76),
      child: EmptyState(
        icon: Icons.credit_card_outlined,
        title: 'cards.emptyTitle'.tr(),
        description: 'cards.emptyDescription'.tr(),
        color: color,
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'cards.securityInfo'.tr(),
              style: const TextStyle(color: Color(0xFFC96A00), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelledField extends StatelessWidget {
  const _LabelledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey)),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        if (showDivider) const Divider(height: 28),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
