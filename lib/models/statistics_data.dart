import 'package:easy_budget/database/database.dart';

/// 통계 데이터를 통합 관리하는 클래스
class StatisticsData {
  final int income;
  final int expense;
  final int? previousBalance;
  final List<CategoryExpenseData> expensesByCategory;
  final List<CategoryExpenseData> incomesByCategory;

  StatisticsData({
    required this.income,
    required this.expense,
    this.previousBalance,
    required this.expensesByCategory,
    required this.incomesByCategory,
  });

  /// 해당 월 잔액 (수입 - 지출)
  int get balance => income - expense;

  /// 전월 이월 포함 총 잔액
  int? get totalBalance =>
      previousBalance != null ? previousBalance! + balance : null;
}
