import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class IncomeExpenseRatioBar extends StatelessWidget {
  final double incomeRatio; // 0.0 ~ 1.0
  final double expenseRatio; // 0.0 ~ 1.0

  const IncomeExpenseRatioBar({
    super.key,
    required this.incomeRatio,
    required this.expenseRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final incomePercent = (incomeRatio * 100).round();
    final expensePercent = (expenseRatio * 100).round();

    return Column(
      children: [
        // 비율 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: incomePercent,
                child: Container(height: 8, color: AppColors.income),
              ),
              Expanded(
                flex: expensePercent,
                child: Container(height: 8, color: AppColors.expense),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 퍼센트 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.income} $incomePercent%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.income,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${l10n.expense} $expensePercent%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.expense,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
