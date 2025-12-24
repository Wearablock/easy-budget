import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  void _previousMonth() {
    onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month - 1));
  }

  void _nextMonth() {
    onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month + 1));
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat.yMMMM(
      Localizations.localeOf(context).languageCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(PhosphorIconsThin.caretLeft),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),

          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                monthFormat.format(selectedMonth),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          IconButton(
            onPressed: _isCurrentMonth ? null : _nextMonth,
            icon: const Icon(PhosphorIconsThin.caretRight),
            style: IconButton.styleFrom(
              backgroundColor: _isCurrentMonth
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      onMonthChanged(DateTime(picked.year, picked.month));
    }
  }
}
