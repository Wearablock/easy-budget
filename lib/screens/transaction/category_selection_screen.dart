import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/transaction/memo_input_screen.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategorySelectionScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final int amountInMinorUnits;

  /// 초기 선택 카테고리 (뒤로가기 후 재진입 시 상태 유지용)
  final Category? initialCategory;

  const CategorySelectionScreen({
    super.key,
    required this.database,
    required this.isIncome,
    required this.amountInMinorUnits,
    this.initialCategory,
  });

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  Category? _selectedCategory;
  List<Category>? _categories;
  String? _error;
  bool _isLoading = true;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // 초기 선택값 설정 (뒤로가기 후 재진입 시)
    _selectedCategory = widget.initialCategory;
    _selectedDate = DateTime.now();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = widget.isIncome
          ? await widget.database.getIncomeCategories()
          : await widget.database.getExpenseCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.category),
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDateSelector(context),

            const Divider(height: 1),

            // 카테고리 그리드
            Expanded(child: _buildCategoryContent()),

            // 다음 버튼
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);
    final formattedDate = dateFormat.format(_selectedDate);

    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIconsThin.calendar,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.date,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isToday
                          ? '${l10n.today} ($formattedDate)'
                          : formattedDate,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsThin.caretRight,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCategoryContent() {
    final l10n = AppLocalizations.of(context);

    // 로딩 상태
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 상태
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsThin.warning,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _loadCategories,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    // 빈 상태
    final categories = _categories ?? [];
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsThin.folderOpen,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCategories,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // 그리드 표시
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory?.id == category.id;

        return _CategoryGridItem(
          category: category,
          isSelected: isSelected,
          onTap: () => _onCategoryTap(category),
        );
      },
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEnabled = _selectedCategory != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: isEnabled ? _onNextPressed : null,
          child: Text(
            l10n.next,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(Category category) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = category;
    });

    // 옵션: 탭 즉시 다음 화면으로 이동 (UX 개선)
    // 아래 주석을 해제하면 카테고리 탭 시 바로 이동
    // _onNextPressed();
  }

  void _onNextPressed() {
    if (_selectedCategory == null) return;

    debugPrint('Selected category: ${_selectedCategory!.nameKey}');
    debugPrint('Amount: ${widget.amountInMinorUnits}');
    debugPrint('Is Income: ${widget.isIncome}');
    debugPrint('Date: $_selectedDate');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoInputScreen(
          database: widget.database,
          isIncome: widget.isIncome,
          amountInMinorUnits: widget.amountInMinorUnits,
          categoryId: _selectedCategory!.id,
          transactionDate: _selectedDate,
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridItem({
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
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: categoryColor, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 원형 배경 + 체크 오버레이
              Stack(
                alignment: Alignment.center,
                children: [
                  // 기본 아이콘
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.25
                            : 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: categoryColor),
                  ),
                  // 선택 체크 오버레이 (AnimatedSwitcher 적용)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('selected'),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PhosphorIconsBold.check,
                              size: 28,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('unselected')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 카테고리 이름
              Text(
                name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? categoryColor
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
