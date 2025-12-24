import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/database/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MonthlySummaryCard extends StatelessWidget {
  final AppDatabase database;
  final int year;
  final int month;

  const MonthlySummaryCard({
    super.key,
    required this.database,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadSummary(),
      builder: (context, snapshot) {
        final income = snapshot.data?['income'] ?? 0;
        final expense = snapshot.data?['expense'] ?? 0;
        final balance = income - expense;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 잔액 (메인)
                _buildBalanceSection(context, balance),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // 수입/지출 상세
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountItem(
                        context: context,
                        label: '수입', // TODO: l10n
                        amount: income,
                        color: AppColors.income,
                        icon: PhosphorIconsThin.arrowDown,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(
                      child: _buildAmountItem(
                        context: context,
                        label: '지출', // TODO: l10n
                        amount: expense,
                        color: AppColors.expense,
                        icon: PhosphorIconsThin.arrowUp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _loadSummary() async {
    final income = await database.getTotalIncomeByMonth(year, month);
    final expense = await database.getTotalExpenseByMonth(year, month);
    return {'income': income, 'expense': expense};
  }

  Widget _buildBalanceSection(BuildContext context, int balance) {
    final isPositive = balance >= 0;
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).languageCode,
      symbol: '₩', // TODO: 동적 화폐 기호
      decimalDigits: 0,
    );

    return Column(
      children: [
        Text(
          '이번 달 잔액', // TODO: l10n
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(balance),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: isPositive ? AppColors.income : AppColors.expense,
            fontWeight: FontWeight.bold,
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
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).languageCode,
      symbol: '₩',
      decimalDigits: 0,
    );

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
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
