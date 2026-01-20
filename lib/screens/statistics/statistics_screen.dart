import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/statistics/category_statistics_screen.dart';
import 'package:easy_budget/screens/statistics/widgets/category_expense_list.dart';
import 'package:easy_budget/screens/statistics/widgets/monthly_trend_section.dart';
import 'package:easy_budget/screens/statistics/widgets/statistics_month_selector.dart';
import 'package:easy_budget/screens/statistics/widgets/statistics_summary_card.dart';
import 'package:easy_budget/services/transaction_notifier.dart';
import 'package:flutter/material.dart';

/// 통계 데이터를 통합 관리하는 클래스
class _StatisticsData {
  final int income;
  final int expense;
  final int? previousBalance;
  final List<CategoryExpenseData> expensesByCategory;
  final List<CategoryExpenseData> incomesByCategory;

  _StatisticsData({
    required this.income,
    required this.expense,
    this.previousBalance,
    required this.expensesByCategory,
    required this.incomesByCategory,
  });
}

class StatisticsScreen extends StatefulWidget {
  final AppDatabase database;

  const StatisticsScreen({super.key, required this.database});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  Future<_StatisticsData>? _dataFuture;

  // 월별 추이 섹션 새로고침을 위한 키
  final GlobalKey<MonthlyTrendSectionState> _trendSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadData();

    // 거래 변경 이벤트 구독
    TransactionNotifier().addListener(_onTransactionChanged);
  }

  @override
  void dispose() {
    TransactionNotifier().removeListener(_onTransactionChanged);
    super.dispose();
  }

  void _onTransactionChanged() {
    refresh();
  }

  /// 외부에서 데이터 새로고침 호출용
  void refresh() {
    _loadData();
    // 월별 추이 섹션도 새로고침
    _trendSectionKey.currentState?.refresh();
    setState(() {});
  }

  void _loadData() {
    _dataFuture = _loadAllData();
  }

  Future<_StatisticsData> _loadAllData() async {
    final income = await widget.database.getTotalIncomeByMonth(
      _selectedYear,
      _selectedMonth,
    );
    final expense = await widget.database.getTotalExpenseByMonth(
      _selectedYear,
      _selectedMonth,
    );

    int? previousBalance;
    try {
      previousBalance = await widget.database.getBalanceBeforeMonth(
        _selectedYear,
        _selectedMonth,
      );
    } catch (_) {
      // 전월 데이터 없음
    }

    final expensesByCategory = await widget.database.getExpensesByCategory(
      _selectedYear,
      _selectedMonth,
    );
    final incomesByCategory = await widget.database.getIncomesByCategory(
      _selectedYear,
      _selectedMonth,
    );

    return _StatisticsData(
      income: income,
      expense: expense,
      previousBalance: previousBalance,
      expensesByCategory: expensesByCategory,
      incomesByCategory: incomesByCategory,
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _loadData();
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _loadData();
    });
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: FutureBuilder<_StatisticsData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 월 선택기
                StatisticsMonthSelector(
                  year: _selectedYear,
                  month: _selectedMonth,
                  onPreviousMonth: _goToPreviousMonth,
                  onNextMonth: _goToNextMonth,
                  onTap: _selectMonth,
                ),

                // 월별 요약 카드
                StatisticsSummaryCard(
                  totalIncome: snapshot.data?.income ?? 0,
                  totalExpense: snapshot.data?.expense ?? 0,
                  previousMonthBalance: snapshot.data?.previousBalance,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                // 월별 추이 차트
                MonthlyTrendSection(
                  key: _trendSectionKey,
                  database: widget.database,
                  selectedYear: _selectedYear,
                  selectedMonth: _selectedMonth,
                ),

                const SizedBox(height: 16),

                // 카테고리별 지출 목록
                CategoryExpenseList(
                  title: l10n.categoryExpenseTitle,
                  expenses: snapshot.data?.expensesByCategory ?? [],
                  maxItems: 5,
                  onViewAll: () => _navigateToCategoryDetails(isIncome: false),
                ),

                const SizedBox(height: 16),

                // 카테고리별 수입 목록
                CategoryExpenseList(
                  title: l10n.categoryIncomeTitle,
                  expenses: snapshot.data?.incomesByCategory ?? [],
                  maxItems: 5,
                  onViewAll: () => _navigateToCategoryDetails(isIncome: true),
                ),

                const SizedBox(height: 80), // FAB 공간
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToCategoryDetails({required bool isIncome}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryStatisticsScreen(
          database: widget.database,
          initialYear: _selectedYear,
          initialMonth: _selectedMonth,
          initialIsIncome: isIncome,
        ),
      ),
    );
  }
}
