import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/chart_type.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChartTypeToggle extends StatelessWidget {
  final ChartType selectedType;
  final ValueChanged<ChartType> onChanged;

  const ChartTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<ChartType>(
      segments: [
        ButtonSegment<ChartType>(
          value: ChartType.bar,
          icon: Icon(PhosphorIconsThin.chartBar, size: 18),
          label: Text(l10n.barChart),
        ),
        ButtonSegment<ChartType>(
          value: ChartType.line,
          icon: Icon(PhosphorIconsThin.chartLine, size: 18),
          label: Text(l10n.lineChart),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
