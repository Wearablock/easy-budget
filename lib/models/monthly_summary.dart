class MonthlySummary {
  final int year;
  final int month;
  final int totalIncome;
  final int totalExpense;
  final int? previousMonthBalance; // 전월 잔액 (비교용)

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    this.previousMonthBalance,
  });

  /// 현재 월 잔액
  int get balance => totalIncome - totalExpense;

  /// 전월 대비 변화량
  int? get balanceChange {
    if (previousMonthBalance == null) return null;
    return balance - previousMonthBalance!;
  }

  /// 전월 대비 변화율 (%)
  double? get balanceChangePercent {
    if (previousMonthBalance == null || previousMonthBalance == 0) return null;
    return (balanceChange! / previousMonthBalance!.abs()) * 100;
  }

  /// 수입 비율 (0.0 ~ 1.0)
  double get incomeRatio {
    final total = totalIncome + totalExpense;
    if (total == 0) return 0.5;
    return totalIncome / total;
  }

  /// 지출 비율 (0.0 ~ 1.0)
  double get expenseRatio => 1 - incomeRatio;
}
