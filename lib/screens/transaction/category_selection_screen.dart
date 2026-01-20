import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/transaction/memo_input_screen.dart';
import 'package:easy_budget/widgets/category_grid_item.dart';
import 'package:easy_budget/widgets/transaction_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategorySelectionScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final int amountInMinorUnits;

  /// 수정 모드용 기존 거래
  final Transaction? existingTransaction;

  /// 초기 선택 카테고리 ID (수정 모드 또는 뒤로가기 후 재진입 시)
  final int? initialCategoryId;

  /// 초기 날짜 (수정 모드용)
  final DateTime? initialDate;

  const CategorySelectionScreen({
    super.key,
    required this.database,
    required this.isIncome,
    required this.amountInMinorUnits,
    this.existingTransaction,
    this.initialCategoryId,
    this.initialDate,
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
    _selectedDate = widget.initialDate ?? DateTime.now();
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

      // 초기 카테고리 ID가 있으면 해당 카테고리 선택
      Category? initialCategory;
      if (widget.initialCategoryId != null) {
        initialCategory = categories.where(
          (c) => c.id == widget.initialCategoryId,
        ).firstOrNull;
      }

      setState(() {
        _categories = categories;
        _selectedCategory = initialCategory;
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
            TransactionDateSelector(
              selectedDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),

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

        return CategoryGridItem(
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoInputScreen(
          database: widget.database,
          isIncome: widget.isIncome,
          amountInMinorUnits: widget.amountInMinorUnits,
          categoryId: _selectedCategory!.id,
          transactionDate: _selectedDate,
          existingTransaction: widget.existingTransaction,
        ),
      ),
    );
  }
}
