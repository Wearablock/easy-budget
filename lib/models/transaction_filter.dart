import 'package:easy_budget/database/database.dart';

enum TransactionFilter {
  all, // 전체
  income, // 수입만
  expense, // 지출만
}

extension TransactionFilterExtension on TransactionFilter {
  List<Transaction> apply(List<Transaction> transactions) {
    switch (this) {
      case TransactionFilter.all:
        return transactions;
      case TransactionFilter.income:
        return transactions.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return transactions.where((t) => !t.isIncome).toList();
    }
  }
}
