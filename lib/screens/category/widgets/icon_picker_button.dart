import 'package:easy_budget/constants/app_spacing.dart';
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
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.inputPadding,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconContainerSm,
              height: AppSpacing.iconContainerSm,
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.15),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(icon, size: 20, color: selectedColor),
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
