import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryListItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(category.color);
    final icon = CategoryIcons.getIcon(category.icon);
    final name = CategoryUtils.getCategoryName(context, category);

    return Semantics(
      label: '$name 카테고리',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(theme, categoryColor, icon),
            const SizedBox(height: 8),
            _buildName(theme, name),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, Color categoryColor, IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: categoryColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.25 : 0.15,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: categoryColor),
    );
  }

  Widget _buildName(ThemeData theme, String name) {
    return Text(
      name,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
