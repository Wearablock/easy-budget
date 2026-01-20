import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';

class PieChartCenterInfo extends StatelessWidget {
  final String? categoryName; // null이면 총합 표시
  final int amount;
  final double? percentage;
  final bool isIncome;

  const PieChartCenterInfo({
    super.key,
    this.categoryName,
    required this.amount,
    this.percentage,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final title = categoryName != null
        ? CategoryUtils.getDisplayName(context, categoryName!)
        : (isIncome ? l10n.totalIncome : l10n.totalExpense);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatWithSymbol(amount),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (percentage != null) ...[
          const SizedBox(height: 2),
          Text(
            '${percentage!.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}
