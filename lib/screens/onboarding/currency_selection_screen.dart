import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:easy_budget/widgets/currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CurrencySelectionScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String? _selectedCode;

  // 지역별로 그룹화된 통화 목록
  static const Map<String, List<String>> _currencyGroups = {
    'Americas': ['USD', 'MXN', 'BRL'],
    'Europe': ['EUR', 'GBP', 'CHF', 'RUB'],
    'Asia': ['KRW', 'JPY', 'CNY', 'TWD', 'HKD', 'INR'],
    'Southeast Asia': ['VND', 'THB', 'IDR'],
    'Middle East': ['SAR'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    PhosphorIconsThin.currencyCircleDollar,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.selectCurrencyTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectCurrencySubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 통화 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _currencyGroups.length,
                itemBuilder: (context, index) {
                  final region = _currencyGroups.keys.elementAt(index);
                  final codes = _currencyGroups[region]!;
                  return _buildRegionSection(context, region, codes);
                },
              ),
            ),
            // 확인 버튼
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSection(
    BuildContext context,
    String region,
    List<String> codes,
  ) {
    final theme = Theme.of(context);
    final regionName = _getLocalizedRegionName(context, region);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            regionName,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        ...codes.map(
          (code) => CurrencyTile(
            code: code,
            isSelected: _selectedCode == code,
            onTap: () {
              setState(() {
                _selectedCode = code;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getLocalizedRegionName(BuildContext context, String region) {
    final l10n = AppLocalizations.of(context);
    switch (region) {
      case 'Americas':
        return l10n.regionAmericas;
      case 'Europe':
        return l10n.regionEurope;
      case 'Asia':
        return l10n.regionAsia;
      case 'Southeast Asia':
        return l10n.regionSoutheastAsia;
      case 'Middle East':
        return l10n.regionMiddleEast;
      default:
        return region;
    }
  }

  Widget _buildConfirmButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEnabled = _selectedCode != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: isEnabled ? _onConfirm : null,
          child: Text(
            l10n.continue_,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (_selectedCode == null) return;

    // 통화 설정 저장
    await PreferencesService.setCurrencyCode(_selectedCode!);
    await PreferencesService.setFirstRunComplete();

    // 메인 화면으로 이동
    widget.onComplete();
  }
}
