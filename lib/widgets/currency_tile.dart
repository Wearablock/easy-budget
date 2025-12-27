import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/currency_config.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 통화 선택 타일 위젯
class CurrencyTile extends StatelessWidget {
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const CurrencyTile({
    super.key,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = CurrencyConfig.fromCode(code);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
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
                        _getCurrencyName(context, config.code),
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

  String _getCurrencyName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'JPY':
        return l10n.currencyJPY;
      case 'KRW':
        return l10n.currencyKRW;
      case 'CNY':
        return l10n.currencyCNY;
      case 'TWD':
        return l10n.currencyTWD;
      case 'HKD':
        return l10n.currencyHKD;
      case 'INR':
        return l10n.currencyINR;
      case 'VND':
        return l10n.currencyVND;
      case 'THB':
        return l10n.currencyTHB;
      case 'IDR':
        return l10n.currencyIDR;
      case 'MXN':
        return l10n.currencyMXN;
      case 'BRL':
        return l10n.currencyBRL;
      case 'CHF':
        return l10n.currencyCHF;
      case 'RUB':
        return l10n.currencyRUB;
      case 'SAR':
        return l10n.currencySAR;
      default:
        return code;
    }
  }
}
