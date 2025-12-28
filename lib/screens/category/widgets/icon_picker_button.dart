import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/widgets/icon_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 아이콘 선택 버튼 (탭하면 바텀시트 열림)
class IconPickerButton extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;

  const IconPickerButton({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final icon = CategoryIcons.getIcon(selectedIcon);

    return InkWell(
      onTap: () => _showIconPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: selectedColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.selectIcon,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              PhosphorIconsThin.caretRight,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showIconPicker(BuildContext context) async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => IconPickerSheet(
        selectedIcon: selectedIcon,
        selectedColor: selectedColor,
      ),
    );

    if (result != null) {
      onIconSelected(result);
    }
  }
}
