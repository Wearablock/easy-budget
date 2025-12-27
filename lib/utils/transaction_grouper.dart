import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/models/daily_transaction_group.dart';

class TransactionGrouper {
  static List<DailyTransactionGroup> groupByDate(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    final Map<DateTime, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final dateOnly = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      grouped.putIfAbsent(dateOnly, () => []);
      grouped[dateOnly]!.add(transaction);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedDates
        .map(
          (date) =>
              DailyTransactionGroup(date: date, transactions: grouped[date]!),
        )
        .toList();
  }

  static DailyTransactionGroup? getGroupForDate(
    List<DailyTransactionGroup> groups,
    DateTime date,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return groups
        .where(
          (g) =>
              g.date.year == dateOnly.year &&
              g.date.month == dateOnly.month &&
              g.date.day == dateOnly.day,
        )
        .firstOrNull;
  }

  static Map<DateTime, int> getDailyNetAmounts(
    List<DailyTransactionGroup> groups,
  ) {
    return {
      for (final group in groups)
        DateTime(group.date.year, group.date.month, group.date.day):
            group.netAmount,
    };
  }
}
