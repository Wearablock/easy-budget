import 'package:easy_budget/constants/category_icons.dart';
import 'package:flutter/material.dart';

class CategoryPreview extends StatelessWidget {
  final String name;
  final String iconKey;
  final Color color;

  const CategoryPreview({
    super.key,
    required this.name,
    required this.iconKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = CategoryIcons.getIcon(iconKey);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.25 : 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            name.isEmpty ? '...' : name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: name.isEmpty
                  ? theme.colorScheme.outline
                  : theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
