import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 아이콘 선택 바텀시트
class IconPickerSheet extends StatefulWidget {
  final String selectedIcon;
  final Color selectedColor;

  const IconPickerSheet({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
  });

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CategoryIcons.categoryOrder.length,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
  }

  int _getInitialTabIndex() {
    // 선택된 아이콘이 속한 카테고리 찾기
    for (int i = 0; i < CategoryIcons.categoryOrder.length; i++) {
      final category = CategoryIcons.categoryOrder[i];
      final icons = CategoryIcons.iconsByCategory[category] ?? [];
      if (icons.contains(widget.selectedIcon)) {
        return i;
      }
    }
    return 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 타이틀
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectIconTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 카테고리 탭
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: CategoryIcons.categoryOrder.map((category) {
                return Tab(
                  text: CategoryIcons.getCategoryName(context, category),
                );
              }).toList(),
            ),

            // 아이콘 그리드
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: CategoryIcons.categoryOrder.map((category) {
                  final icons = CategoryIcons.iconsByCategory[category] ?? [];
                  return _buildIconGrid(icons, scrollController);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconGrid(List<String> icons, ScrollController scrollController) {
    final theme = Theme.of(context);

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconKey = icons[index];
        final isSelected = iconKey == widget.selectedIcon;
        final icon = CategoryIcons.getIcon(iconKey);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(iconKey);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.selectedColor.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: widget.selectedColor, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected
                  ? widget.selectedColor
                  : theme.colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }
}
