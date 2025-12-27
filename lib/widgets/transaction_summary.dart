import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 거래 요약 위젯 (금액, 날짜, 아이콘 표시)
class TransactionSummary extends StatelessWidget {
  final int amountInMinorUnits;
  final bool isIncome;
  final DateTime transactionDate;

  const TransactionSummary({
    super.key,
    required this.amountInMinorUnits,
    required this.isIncome,
    required this.transactionDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedAmount = CurrencyUtils.formatWithSymbol(amountInMinorUnits);
    final color = isIncome ? theme.colorScheme.primary : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncome ? '+$formattedAmount' : '-$formattedAmount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transactionDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? PhosphorIconsThin.arrowUp : PhosphorIconsThin.arrowDown,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
