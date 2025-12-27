import 'package:easy_budget/database/database.dart';

class DailyTransactionGroup {
  final DateTime date;
  final List<Transaction> transactions;

  DailyTransactionGroup({required this.date, required this.transactions});

  int get totalIncome =>
      transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);

  int get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get netAmount => totalIncome - totalExpense;

  int get transactionCount => transactions.length;
}
