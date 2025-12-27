import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final int amountInMinorUnits;
  final bool isIncome;
  final CurrencyConfig? currency;
  final VoidCallback? onTap;

  const AmountDisplay({
    super.key,
    required this.amountInMinorUnits,
    required this.isIncome,
    this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = currency ?? CurrencyUtils.currentCurrency;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            if (config.symbolBefore) ...[
              Text(
                config.symbol,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
            ],

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                _buildDisplayText(config),
                key: ValueKey(amountInMinorUnits),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (!config.symbolBefore) ...[
              const SizedBox(height: 8),
              Text(
                config.symbol,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],

            const SizedBox(height: 8),

            if (amountInMinorUnits == 0)
              Text(
                AppLocalizations.of(context).enterAmount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDisplayText(CurrencyConfig config) {
    if (amountInMinorUnits == 0) {
      if (config.hasDecimals) {
        return '0${config.decimalSeparator}${'0' * config.decimalPlaces}';
      }
      return '0';
    }
    return CurrencyUtils.formatAmount(amountInMinorUnits, currency: config);
  }
}
