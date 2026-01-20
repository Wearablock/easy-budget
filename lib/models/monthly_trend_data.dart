import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class MonthlyTrendData {
  final int year;
  final int month;
  final int income;
  final int expense;
  final int? cumulativeBalance; // 누적 잔액 (라인 차트용)

  MonthlyTrendData({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    this.cumulativeBalance,
  });

  /// 해당 월의 잔액 (수입 - 지출)
  int get balance => income - expense;

  /// 월 표시 문자열 (예: "12월", "Jan")
  String getMonthLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final date = DateTime(year, month);

    if (locale.languageCode == 'ko') {
      return '$month월';
    } else {
      return DateFormat.MMM(locale.toString()).format(date);
    }
  }

  /// 전체 날짜 표시 (예: "2024년 12월", "Dec 2024")
  String getFullLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final date = DateTime(year, month);

    if (locale.languageCode == 'ko') {
      return '$year년 $month월';
    } else {
      return DateFormat.yMMM(locale.toString()).format(date);
    }
  }

  MonthlyTrendData copyWith({
    int? year,
    int? month,
    int? income,
    int? expense,
    int? cumulativeBalance,
  }) {
    return MonthlyTrendData(
      year: year ?? this.year,
      month: month ?? this.month,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      cumulativeBalance: cumulativeBalance ?? this.cumulativeBalance,
    );
  }
}
