import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/statistics/widgets/pie_chart_center_info.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryExpenseData> data;
  final int totalAmount;
  final bool isIncome;
  final ValueChanged<int?>? onSectionTouched;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.totalAmount,
    required this.isIncome,
    this.onSectionTouched,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    // 선택된 섹션 정보
    final selectedData =
        _touchedIndex != null && _touchedIndex! < widget.data.length
        ? widget.data[_touchedIndex!]
        : null;

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 파이 차트
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    if (_touchedIndex != null) {
                      setState(() => _touchedIndex = null);
                      widget.onSectionTouched?.call(null);
                    }
                    return;
                  }

                  final newIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                  if (newIndex != _touchedIndex && newIndex >= 0) {
                    HapticFeedback.lightImpact();
                    setState(() => _touchedIndex = newIndex);
                    widget.onSectionTouched?.call(
                      widget.data[newIndex].categoryId,
                    );
                  }
                },
              ),
              sections: _buildSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),

          // 중앙 정보
          PieChartCenterInfo(
            categoryName: selectedData?.categoryName,
            amount: selectedData?.amount ?? widget.totalAmount,
            percentage: selectedData?.percentage,
            isIncome: widget.isIncome,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;

      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: Color(data.colorValue),
        value: data.amount.toDouble(),
        title: data.percentage >= 5
            ? '${data.percentage.toStringAsFixed(0)}%'
            : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.55,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsThin.chartPieSlice,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isIncome ? l10n.noIncomeData : l10n.noExpenseData,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
