import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final AppDatabase database;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.database,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category?>(
      future: database.getCategoryById(transaction.categoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 카테고리 아이콘
                  _buildCategoryIcon(context, category),
                  const SizedBox(width: 12),

                  // 카테고리명 + 메모
                  Expanded(child: _buildTransactionInfo(context, category)),

                  // 금액
                  _buildAmount(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(BuildContext context, Category? category) {
    final iconData = category != null
        ? CategoryIcons.getIcon(category.icon)
        : PhosphorIconsThin.question;
    final color = category != null
        ? Color(category.color)
        : Theme.of(context).colorScheme.outline;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 22),
    );
  }

  Widget _buildTransactionInfo(BuildContext context, Category? category) {
    // 카테고리 이름 (TODO: l10n 적용)
    final categoryName =
        category?.customName ??
        CategoryUtils.getLocalizedName(context, category?.nameKey ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName.isNotEmpty ? categoryName : '알 수 없음',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            transaction.memo!,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 2),
        Text(
          _formatDate(context),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final prefix = isIncome ? '+' : '-';

    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).languageCode,
      symbol: '₩',
      decimalDigits: 0,
    );

    return Text(
      '$prefix${currencyFormat.format(transaction.amount)}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.MMMd(locale);
    return dateFormat.format(transaction.transactionDate);
  }
}
