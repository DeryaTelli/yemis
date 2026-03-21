import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/locale_keys.dart';
import '../../utils/theme/app_theme.dart';

class LanguageSelectView extends StatefulWidget {
  final AppSection section;

  const LanguageSelectView({super.key, required this.section});

  @override
  State<LanguageSelectView> createState() => _LanguageSelectViewState();
}

class _LanguageSelectViewState extends State<LanguageSelectView> {
  late String _selectedLocale;

  Color get _themeColor => widget.section == AppSection.volunteer
      ? AppColors.volunteerColor
      : AppColors.primaryColor;

  Color get _bgColor => widget.section == AppSection.volunteer
      ? AppColors.volunteerColor.withValues(alpha: 0.12)
      : const Color(0xFFFFF5E9);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale.languageCode;
  }

  String get _selectedLabel {
    if (_selectedLocale == 'en') {
      return LocaleKeys.languageSelect_english.tr();
    }
    return LocaleKeys.languageSelect_turkish.tr();
  }

  Future<void> _showLanguagePicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _LanguageOption(
                  label: LocaleKeys.languageSelect_turkish.tr(),
                  locale: 'tr',
                  selected: _selectedLocale == 'tr',
                  themeColor: _themeColor,
                ),
                _LanguageOption(
                  label: LocaleKeys.languageSelect_english.tr(),
                  locale: 'en',
                  selected: _selectedLocale == 'en',
                  themeColor: _themeColor,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null && picked != _selectedLocale) {
      setState(() => _selectedLocale = picked);
    }
  }

  void _confirm() {
    context.setLocale(Locale(_selectedLocale));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(widget.section),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(LocaleKeys.languageSelect_title.tr()),
          leading: BackButton(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Language illustration
              Center(
                child: Image.asset(
                  'assets/common/language.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              // Description text
              Text(
                LocaleKeys.languageSelect_description.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
              ),

              const SizedBox(height: 28),

              // Dropdown selector
              GestureDetector(
                onTap: _showLanguagePicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _themeColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _themeColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _themeColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Confirm button
              CustomButton(
                text: LocaleKeys.languageSelect_confirmButton.tr(),
                onPressed: _confirm,
                width: double.infinity,
                height: 52,
                borderRadius: 14,
                gradient: widget.section == AppSection.volunteer
                    ? AppColors.volunteerBackgroundGradient
                    : AppColors.primaryButtonGradient,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet option row ───────────────────────────────────────────────
class _LanguageOption extends StatelessWidget {
  final String label;
  final String locale;
  final bool selected;
  final Color themeColor;

  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.selected,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(locale),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? themeColor : const Color(0xFF555555),
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: themeColor, size: 22),
          ],
        ),
      ),
    );
  }
}
