import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';
import 'package:money_mate/data/repositories/app_settings_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/currency/current_currency.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class CurrencySettingScreen extends StatefulWidget {
  const CurrencySettingScreen({super.key});

  @override
  State<CurrencySettingScreen> createState() => _CurrencySettingScreenState();
}

class _CurrencySettingScreenState extends State<CurrencySettingScreen> {
  final AppSettingsRepository _repository = AppSettingsRepositoryImpl();
  late CurrencyCode _selected = CurrentCurrency.code;

  Future<void> _onSelect(CurrencyCode code) async {
    if (code == _selected) return;
    setState(() => _selected = code);
    await _repository.setMainCurrency(code);
    CurrentCurrency.code = code;
  }

  String _nameFor(CurrencyCode code, AppLocalizations l10n) {
    switch (code) {
      case CurrencyCode.krw:
        return l10n.currencyNameKrw;
      case CurrencyCode.usd:
        return l10n.currencyNameUsd;
      case CurrencyCode.jpy:
        return l10n.currencyNameJpy;
      case CurrencyCode.eur:
        return l10n.currencyNameEur;
      case CurrencyCode.cny:
        return l10n.currencyNameCny;
      case CurrencyCode.gbp:
        return l10n.currencyNameGbp;
      case CurrencyCode.hkd:
        return l10n.currencyNameHkd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              title: l10n.currencySettingScreenTitle,
              onBackTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    l10n.currencySettingDescription,
                    style: TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final code in CurrencyCode.values) ...[
                    _CurrencyRow(
                      code: code,
                      name: _nameFor(code, l10n),
                      selected: code == _selected,
                      onTap: () => _onSelect(code),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBackTap});

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onBackTap,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final CurrencyCode code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = context.appColors.primary;
    final selectedBackgroundColor = selectedColor.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.1,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? selectedBackgroundColor : context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? selectedColor : context.appColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.isoCode,
                    style: TextStyle(
                      fontSize: 15,
                      height: 20 / 15,
                      fontWeight: FontWeight.w700,
                      color:
                          selected
                              ? selectedColor
                              : context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 22, color: selectedColor)
            else
              Icon(
                Icons.circle_outlined,
                size: 22,
                color: context.appColors.border,
              ),
          ],
        ),
      ),
    );
  }
}
