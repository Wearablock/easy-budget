import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/services/preferences_service.dart';
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
                    'Select Your Currency',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the currency you use most often',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            region,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        ...codes.map((code) => _buildCurrencyTile(context, code)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCurrencyTile(BuildContext context, String code) {
    final theme = Theme.of(context);
    final config = CurrencyConfig.fromCode(code);
    final isSelected = _selectedCode == code;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCode = code;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 통화 기호
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    config.symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 통화 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.code,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w500 : null,
                        ),
                      ),
                      Text(
                        _getCurrencyName(config.code),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // 체크 아이콘
                if (isSelected)
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final isEnabled = _selectedCode != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: isEnabled ? _onConfirm : null,
          child: const Text(
            'Continue',
            style: TextStyle(
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

  String _getCurrencyName(String code) {
    const names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'KRW': 'Korean Won',
      'CNY': 'Chinese Yuan',
      'TWD': 'Taiwan Dollar',
      'HKD': 'Hong Kong Dollar',
      'INR': 'Indian Rupee',
      'VND': 'Vietnamese Dong',
      'THB': 'Thai Baht',
      'IDR': 'Indonesian Rupiah',
      'MXN': 'Mexican Peso',
      'BRL': 'Brazilian Real',
      'CHF': 'Swiss Franc',
      'RUB': 'Russian Ruble',
      'SAR': 'Saudi Riyal',
    };
    return names[code] ?? code;
  }
}
