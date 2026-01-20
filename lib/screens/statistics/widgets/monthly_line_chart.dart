import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/monthly_trend_data.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MonthlyLineChart extends StatefulWidget {
  final List<MonthlyTrendData> data;
  final int selectedYear;
  final int selectedMonth;
  final ValueChanged<MonthlyTrendData>? onPointTouched;

  const MonthlyLineChart({
    super.key,
    required this.data,
    required this.selectedYear,
    required this.selectedMonth,
    this.onPointTouched,
  });

  @override
  State<MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<MonthlyLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    // 잔액 기준 최소/최대값 계산
    final balances = widget.data.map((d) => d.balance).toList();
    final minBalance = balances.reduce((a, b) => a < b ? a : b);
    final maxBalance = balances.reduce((a, b) => a > b ? a : b);

    // Y축 범위 (여유 공간 20%, 최소값 보장)
    final range = maxBalance - minBalance;
    final padding = range == 0
        ? (maxBalance.abs() == 0 ? 1000.0 : maxBalance.abs() * 0.2)
        : range * 0.2;
    final yAxisMin = (minBalance - padding).toDouble();
    final yAxisMax = (maxBalance + padding).toDouble();

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 16, top: 16),
        child: LineChart(
          LineChartData(
            minY: yAxisMin,
            maxY: yAxisMax,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) =>
                    theme.colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final data = widget.data[spot.x.toInt()];
                    final balance = data.balance;
                    final isPositive = balance >= 0;

                    return LineTooltipItem(
                      '${data.getFullLabel(context)}\\n',
                      TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '${l10n.balanceLabel}: ',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${isPositive ? '+' : ''}${CurrencyUtils.formatCompact(balance)}',
                          style: TextStyle(
                            color: isPositive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.lineBarSpots == null ||
                    response.lineBarSpots!.isEmpty) {
                  if (_touchedIndex != null) {
                    setState(() => _touchedIndex = null);
                  }
                  return;
                }

                final index = response.lineBarSpots!.first.x.toInt();
                if (index != _touchedIndex && index >= 0) {
                  HapticFeedback.lightImpact();
                  setState(() => _touchedIndex = index);
                  widget.onPointTouched?.call(widget.data[index]);
                }
              },
              handleBuiltInTouches: true,
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
                  interval: 1,
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
              getDrawingHorizontalLine: (value) {
                // 0선 강조
                if (value == 0) {
                  return FlLine(
                    color: theme.colorScheme.outline,
                    strokeWidth: 1,
                  );
                }
                return FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [_buildLineData(theme)],
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  LineChartBarData _buildLineData(ThemeData theme) {
    return LineChartBarData(
      spots: widget.data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.balance.toDouble());
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: theme.colorScheme.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) {
          final data = widget.data[index];
          final isSelected =
              data.year == widget.selectedYear &&
              data.month == widget.selectedMonth;
          final isTouched = index == _touchedIndex;

          return FlDotCirclePainter(
            radius: isSelected || isTouched ? 6 : 4,
            color: theme.colorScheme.primary,
            strokeWidth: 2,
            strokeColor: theme.colorScheme.surface,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.primary.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
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
