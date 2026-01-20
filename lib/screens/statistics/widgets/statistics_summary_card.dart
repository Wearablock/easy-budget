import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/statistics/widgets/income_expense_ratio_bar.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:easy_budget/widgets/animated_amount.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatisticsSummaryCard extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;
  final int? previousMonthBalance; // 전월 잔액 (null이면 표시 안 함)
  final bool isLoading; // 로딩 상태

  const StatisticsSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    this.previousMonthBalance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // 로딩 상태 처리
    if (isLoading) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    final balance = totalIncome - totalExpense;
    final isPositive = balance >= 0;

    // 수입/지출 비율 계산
    final total = totalIncome + totalExpense;
    final incomeRatio = total > 0 ? totalIncome / total : 0.5;
    final expenseRatio = 1 - incomeRatio;

    // 전월 대비 계산
    int? balanceChange;
    double? changePercent;
    if (previousMonthBalance != null) {
      balanceChange = balance - previousMonthBalance!;
      if (previousMonthBalance != 0) {
        changePercent = (balanceChange / previousMonthBalance!.abs()) * 100;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 월간 잔액 섹션
            _buildBalanceSection(
              context: context,
              balance: balance,
              isPositive: isPositive,
              balanceChange: balanceChange,
              changePercent: changePercent,
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // 수입/지출 상세
            Row(
              children: [
                Expanded(
                  child: _buildAmountItem(
                    context: context,
                    label: l10n.income,
                    amount: totalIncome,
                    color: AppColors.income,
                    icon: PhosphorIconsThin.arrowDown,
                  ),
                ),
                Container(width: 1, height: 50, color: theme.dividerColor),
                Expanded(
                  child: _buildAmountItem(
                    context: context,
                    label: l10n.expense,
                    amount: totalExpense,
                    color: AppColors.expense,
                    icon: PhosphorIconsThin.arrowUp,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 수입/지출 비율 바
            if (total > 0)
              IncomeExpenseRatioBar(
                incomeRatio: incomeRatio,
                expenseRatio: expenseRatio,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection({
    required BuildContext context,
    required int balance,
    required bool isPositive,
    int? balanceChange,
    double? changePercent,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.monthlyBalance,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedAmount(
          amount: balance,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: isPositive ? AppColors.income : AppColors.expense,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 전월 대비 (선택적)
        if (balanceChange != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildChangeIndicator(
              context: context,
              change: balanceChange,
              percent: changePercent,
            ),
          ),
      ],
    );
  }

  Widget _buildChangeIndicator({
    required BuildContext context,
    required int change,
    double? percent,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isPositive = change >= 0;
    final color = isPositive ? AppColors.income : AppColors.expense;
    final icon = isPositive
        ? PhosphorIconsThin.trendUp
        : PhosphorIconsThin.trendDown;

    String text =
        '${isPositive ? '+' : ''}${CurrencyUtils.formatWithSymbol(change)}';
    if (percent != null) {
      text += ' (${percent.toStringAsFixed(1)}%)';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          l10n.vsLastMonth,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountItem({
    required BuildContext context,
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedAmount(
          amount: amount,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
