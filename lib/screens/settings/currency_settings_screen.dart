import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:easy_budget/widgets/currency_tile.dart';
import 'package:flutter/material.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
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
  void initState() {
    super.initState();
    _selectedCode = CurrencyUtils.currentCurrency.code;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectCurrency),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _currencyGroups.length,
        itemBuilder: (context, index) {
          final region = _currencyGroups.keys.elementAt(index);
          final codes = _currencyGroups[region]!;
          return _buildRegionSection(context, region, codes);
        },
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
            onTap: () => _onCurrencySelected(code),
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

  Future<void> _onCurrencySelected(String code) async {
    setState(() {
      _selectedCode = code;
    });

    // 통화 설정 저장
    await PreferencesService.setCurrencyCode(code);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.currencyChanged),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }
}
