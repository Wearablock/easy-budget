import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/monthly_trend_data.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MonthlyBarChart extends StatefulWidget {
  final List<MonthlyTrendData> data;
  final int selectedYear;
  final int selectedMonth;
  final ValueChanged<MonthlyTrendData>? onBarTouched;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.selectedYear,
    required this.selectedMonth,
    this.onBarTouched,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    // 최대값 계산 (Y축 스케일용)
    final maxValue = widget.data.fold<int>(0, (max, data) {
      final bigger = data.income > data.expense ? data.income : data.expense;
      return bigger > max ? bigger : max;
    });

    // Y축 최대값 (여유 공간 20%, 최소값 보장)
    final yAxisMax = maxValue == 0 ? 1000.0 : maxValue * 1.2;

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            maxY: yAxisMax.toDouble(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) =>
                    theme.colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final data = widget.data[groupIndex];
                  final isIncome = rodIndex == 0;

                  return BarTooltipItem(
                    '${data.getFullLabel(context)}\\n',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${isIncome ? l10n.incomeLabel : l10n.expenseLabel}: ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: CurrencyUtils.formatCompact(
                          isIncome ? data.income : data.expense,
                        ),
                        style: TextStyle(
                          color: isIncome
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.spot == null) {
                  if (_touchedIndex != null) {
                    setState(() => _touchedIndex = null);
                  }
                  return;
                }

                final index = response.spot!.touchedBarGroupIndex;
                if (index != _touchedIndex && index >= 0) {
                  HapticFeedback.lightImpact();
                  setState(() => _touchedIndex = index);
                  widget.onBarTouched?.call(widget.data[index]);
                }
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= widget.data.length) {
                      return const SizedBox.shrink();
                    }

                    final data = widget.data[index];
                    final isSelected =
                        data.year == widget.selectedYear &&
                        data.month == widget.selectedMonth;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data.getMonthLabel(context),
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }

                    return Text(
                      CurrencyUtils.formatCompact(value.toInt()),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yAxisMax / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: _buildBarGroups(theme, yAxisMax),
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme, double yAxisMax) {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final isSelected =
          data.year == widget.selectedYear &&
          data.month == widget.selectedMonth;

      final incomeColor = theme.colorScheme.primary;
      final expenseColor = theme.colorScheme.error;

      return BarChartGroupData(
        x: index,
        barRods: [
          // 수입 바
          BarChartRodData(
            toY: data.income.toDouble(),
            color: isTouched || isSelected
                ? incomeColor
                : incomeColor.withValues(alpha: 0.7),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          // 지출 바
          BarChartRodData(
            toY: data.expense.toDouble(),
            color: isTouched || isSelected
                ? expenseColor
                : expenseColor.withValues(alpha: 0.7),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 220,
      child: Center(
        child: Text(
          l10n.noTrendData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
