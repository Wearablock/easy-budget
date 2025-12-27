import 'package:easy_budget/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 거래 필터 칩 위젯
class TransactionFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color? activeColor;
  final VoidCallback onTap;

  const TransactionFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color selectedBgColor;
    final Color selectedFgColor;

    if (isSelected) {
      if (activeColor != null) {
        selectedBgColor = activeColor!.withValues(alpha: 0.15);
        selectedFgColor = activeColor!;
      } else {
        selectedBgColor = AppColors.primary.withValues(alpha: 0.15);
        selectedFgColor = AppColors.primary;
      }
    } else {
      selectedBgColor = Colors.transparent;
      selectedFgColor = isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selectedBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selectedFgColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selectedFgColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
