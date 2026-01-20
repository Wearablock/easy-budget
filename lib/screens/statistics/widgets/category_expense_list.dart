import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/statistics/widgets/category_expense_item.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryExpenseList extends StatelessWidget {
  final String? title; // 커스텀 제목 (null이면 기본 지출 제목 사용)
  final List<CategoryExpenseData> expenses;
  final int maxItems; // 표시할 최대 개수 (기본 5개)
  final VoidCallback? onViewAll;

  const CategoryExpenseList({
    super.key,
    this.title,
    required this.expenses,
    this.maxItems = 5,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final displayItems = expenses.take(maxItems).toList();

    if (expenses.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                PhosphorIconsThin.chartPieSlice,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noExpenseData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? l10n.categoryExpenseTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.viewAll),
                        const SizedBox(width: 4),
                        const Icon(PhosphorIconsThin.caretRight, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 카테고리별 지출 아이템들
            ...displayItems.map(
              (expense) => CategoryExpenseItem(
                categoryName: expense.categoryName,
                iconName: expense.iconName,
                color: Color(expense.colorValue),
                amount: expense.amount,
                percentage: expense.percentage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
