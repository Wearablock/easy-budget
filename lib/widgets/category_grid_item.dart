import 'package:easy_budget/constants/app_spacing.dart';
import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 카테고리 그리드 아이템 위젯
class CategoryGridItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(category.color);
    final icon = CategoryIcons.getIcon(category.icon);
    final name = CategoryUtils.getCategoryName(context, category);

    return Semantics(
      label: '$name 카테고리, ${isSelected ? "선택됨" : "선택 안됨"}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: isSelected
                ? Border.all(color: categoryColor, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconWithOverlay(theme, categoryColor, icon),
              const SizedBox(height: 8),
              _buildCategoryName(theme, categoryColor, name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithOverlay(
    ThemeData theme,
    Color categoryColor,
    IconData icon,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 기본 아이콘
        Container(
          width: AppSpacing.iconContainerLg,
          height: AppSpacing.iconContainerLg,
          decoration: BoxDecoration(
            color: categoryColor.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.25 : 0.15,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: categoryColor),
        ),
        // 선택 체크 오버레이
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              ? Container(
                  key: const ValueKey('selected'),
                  width: AppSpacing.iconContainerLg,
                  height: AppSpacing.iconContainerLg,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsBold.check,
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('unselected')),
        ),
      ],
    );
  }

  Widget _buildCategoryName(
    ThemeData theme,
    Color categoryColor,
    String name,
  ) {
    return Text(
      name,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? categoryColor : theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
