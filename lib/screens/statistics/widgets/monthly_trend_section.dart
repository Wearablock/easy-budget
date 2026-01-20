import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/chart_type.dart';
import 'package:easy_budget/models/monthly_trend_data.dart';
import 'package:easy_budget/screens/statistics/widgets/chart_type_toggle.dart';
import 'package:easy_budget/screens/statistics/widgets/monthly_bar_chart.dart';
import 'package:easy_budget/screens/statistics/widgets/monthly_line_chart.dart';
import 'package:flutter/material.dart';

class MonthlyTrendSection extends StatefulWidget {
  final AppDatabase database;
  final int selectedYear;
  final int selectedMonth;

  const MonthlyTrendSection({
    super.key,
    required this.database,
    required this.selectedYear,
    required this.selectedMonth,
  });

  @override
  State<MonthlyTrendSection> createState() => MonthlyTrendSectionState();
}

class MonthlyTrendSectionState extends State<MonthlyTrendSection> {
  ChartType _chartType = ChartType.bar;
  Future<List<MonthlyTrendData>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MonthlyTrendSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      _loadData();
    }
  }

  void _loadData() {
    _dataFuture = widget.database.getMonthlyTrends(
      endYear: widget.selectedYear,
      endMonth: widget.selectedMonth,
      monthCount: 6,
    );
  }

  /// 외부에서 데이터 새로고침 호출용
  void refresh() {
    _loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 + 토글
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.monthlyTrend,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ChartTypeToggle(
                  selectedType: _chartType,
                  onChanged: (type) {
                    setState(() => _chartType = type);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 차트
            FutureBuilder<List<MonthlyTrendData>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = snapshot.data ?? [];

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _chartType == ChartType.bar
                      ? MonthlyBarChart(
                          key: const ValueKey('bar'),
                          data: data,
                          selectedYear: widget.selectedYear,
                          selectedMonth: widget.selectedMonth,
                        )
                      : MonthlyLineChart(
                          key: const ValueKey('line'),
                          data: data,
                          selectedYear: widget.selectedYear,
                          selectedMonth: widget.selectedMonth,
                        ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 범례
            _buildLegend(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, AppLocalizations l10n) {
    if (_chartType == ChartType.bar) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(theme.colorScheme.primary, l10n.incomeLabel, theme),
          const SizedBox(width: 24),
          _buildLegendItem(theme.colorScheme.error, l10n.expenseLabel, theme),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            theme.colorScheme.primary,
            l10n.monthlyBalance,
            theme,
          ),
        ],
      );
    }
  }

  Widget _buildLegendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
