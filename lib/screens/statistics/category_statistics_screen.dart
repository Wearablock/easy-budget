import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/statistics/widgets/category_expense_item.dart';
import 'package:easy_budget/screens/statistics/widgets/category_pie_chart.dart';
import 'package:easy_budget/screens/statistics/widgets/statistics_month_selector.dart';
import 'package:flutter/material.dart';

class CategoryStatisticsScreen extends StatefulWidget {
  final AppDatabase database;
  final int initialYear;
  final int initialMonth;
  final bool initialIsIncome;

  const CategoryStatisticsScreen({
    super.key,
    required this.database,
    required this.initialYear,
    required this.initialMonth,
    this.initialIsIncome = false,
  });

  @override
  State<CategoryStatisticsScreen> createState() =>
      _CategoryStatisticsScreenState();
}

class _CategoryStatisticsScreenState extends State<CategoryStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedYear;
  late int _selectedMonth;
  late TabController _tabController;
  int? _highlightedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIsIncome ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _highlightedCategoryId = null;
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
      _highlightedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryStatisticsTitle)),
      body: Column(
        children: [
          // 월 선택기
          StatisticsMonthSelector(
            year: _selectedYear,
            month: _selectedMonth,
            onPreviousMonth: _goToPreviousMonth,
            onNextMonth: _goToNextMonth,
          ),

          // 지출/수입 탭
          TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: l10n.expense),
              Tab(text: l10n.income),
            ],
            onTap: (_) {
              setState(() => _highlightedCategoryId = null);
            },
          ),

          // 탭 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 지출 탭
                _buildCategoryContent(isIncome: false),
                // 수입 탭
                _buildCategoryContent(isIncome: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent({required bool isIncome}) {
    return FutureBuilder<List<CategoryExpenseData>>(
      future: isIncome
          ? widget.database.getIncomesByCategory(_selectedYear, _selectedMonth)
          : widget.database.getExpensesByCategory(
              _selectedYear,
              _selectedMonth,
            ),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        final totalAmount = data.fold<int>(0, (sum, item) => sum + item.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // 파이 차트
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CategoryPieChart(
                  data: data,
                  totalAmount: totalAmount,
                  isIncome: isIncome,
                  onSectionTouched: (categoryId) {
                    setState(() => _highlightedCategoryId = categoryId);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 카테고리 목록
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncome
                            ? AppLocalizations.of(context).income
                            : AppLocalizations.of(context).expense,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (data.isEmpty)
                        _buildEmptyListState(context, isIncome)
                      else
                        ...data.map((item) => _buildCategoryItem(item)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(CategoryExpenseData item) {
    final isHighlighted = _highlightedCategoryId == item.categoryId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Color(item.colorValue).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CategoryExpenseItem(
        categoryName: item.categoryName,
        iconName: item.iconName,
        color: Color(item.colorValue),
        amount: item.amount,
        percentage: item.percentage,
      ),
    );
  }

  Widget _buildEmptyListState(BuildContext context, bool isIncome) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          isIncome ? l10n.noIncomeData : l10n.noExpenseData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
