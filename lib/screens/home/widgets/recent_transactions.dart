import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/transaction/add_transaction_screen.dart';
import 'package:easy_budget/screens/transaction/transaction_list_screen.dart';
import 'package:easy_budget/widgets/dismissible_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RecentTransactions extends StatelessWidget {
  final AppDatabase database;
  final int year;
  final int month;

  const RecentTransactions({
    super.key,
    required this.database,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).recentTransactions,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => _openTransactionList(context),
                child: Text(AppLocalizations.of(context).viewAll),
              ),
            ],
          ),
        ),

        // 거래 목록
        Expanded(
          child: StreamBuilder<List<Transaction>>(
            stream: database.watchTransactionsByMonth(year, month),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data ?? [];

              if (transactions.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return DismissibleTransactionTile(
                    transaction: transaction,
                    database: database,
                    onTap: () => _openEditTransaction(context, transaction),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openTransactionList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionListScreen(
          database: database,
          initialYear: year,
          initialMonth: month,
        ),
      ),
    );
  }

  void _openEditTransaction(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          database: database,
          existingTransaction: transaction,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsThin.receipt,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noTransactions,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).addFirstTransaction,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
