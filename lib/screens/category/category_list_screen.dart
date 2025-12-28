import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/add_category_screen.dart';
import 'package:easy_budget/screens/category/edit_category_screen.dart';
import 'package:easy_budget/screens/category/widgets/category_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryListScreen extends StatefulWidget {
  final AppDatabase database;

  const CategoryListScreen({super.key, required this.database});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryManagement),
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: l10n.expense),
            Tab(text: l10n.income),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab(isIncome: false),
          _buildCategoryTab(isIncome: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddCategory,
        heroTag: 'category_fab',
        child: const Icon(PhosphorIconsBold.plus),
      ),
    );
  }

  Widget _buildCategoryTab({required bool isIncome}) {
    final stream = isIncome
        ? widget.database.watchIncomeCategories()
        : widget.database.watchExpenseCategories();

    return StreamBuilder<List<Category>>(
      stream: stream,
      builder: (context, snapshot) {
        // 로딩 상태
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 에러 상태
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // 데이터 표시
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCategoryGrid(categories);
      },
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
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
        return CategoryListItem(
          category: category,
          onTap: () => _onCategoryTap(category),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsThin.folderOpen,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noCategoriesInList,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapPlusToAddCategory,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsThin.warning,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(l10n.errorOccurred, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(Category category) {
    HapticFeedback.lightImpact();

    // 기본 카테고리는 수정 불가
    if (category.isDefault) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotEditDefaultCategory),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditCategoryScreen(database: widget.database, category: category),
      ),
    );
  }

  void _onAddCategory() {
    HapticFeedback.lightImpact();

    final isIncome = _tabController.index == 1;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddCategoryScreen(database: widget.database, isIncome: isIncome),
      ),
    );
  }
}
