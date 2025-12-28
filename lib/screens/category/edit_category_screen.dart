import 'package:drift/drift.dart' hide Column;
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/widgets/category_preview.dart';
import 'package:easy_budget/screens/category/widgets/color_picker.dart';
import 'package:easy_budget/screens/category/widgets/delete_category_dialog.dart';
import 'package:easy_budget/screens/category/widgets/icon_picker_button.dart';
import 'package:easy_budget/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 카테고리 수정 화면
class EditCategoryScreen extends StatefulWidget {
  final AppDatabase database;
  final Category category;

  const EditCategoryScreen({
    super.key,
    required this.database,
    required this.category,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _selectedIcon;
  late Color _selectedColor;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isInitialized = false;

  bool get _isDefaultCategory => widget.category.isDefault;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.category.icon;
    _selectedColor = Color(widget.category.color);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 최초 한 번만 이름 초기화 (context 사용 가능)
    if (!_isInitialized) {
      _nameController.text = CategoryUtils.getCategoryName(
        context,
        widget.category,
      );
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCategoryTitle),
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 삭제 버튼 (커스텀 카테고리만)
          if (!_isDefaultCategory)
            IconButton(
              icon: Icon(
                PhosphorIconsThin.trash,
                color: theme.colorScheme.error,
              ),
              onPressed: _isDeleting ? null : _showDeleteDialog,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 미리보기
              CategoryPreview(
                name: _nameController.text,
                iconKey: _selectedIcon,
                color: _selectedColor,
              ),

              const SizedBox(height: 24),

              // 이름 입력
              Text(
                l10n.categoryName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_isDefaultCategory, // 기본 카테고리는 비활성
                decoration: InputDecoration(
                  hintText: l10n.categoryNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: _isDefaultCategory,
                  fillColor: _isDefaultCategory
                      ? theme.colorScheme.surfaceContainerHighest
                      : null,
                ),
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (_isDefaultCategory) return null; // 기본 카테고리는 검증 스킵
                  if (value == null || value.trim().isEmpty) {
                    return l10n.categoryNameRequired;
                  }
                  if (value.length > 20) {
                    return l10n.categoryNameTooLong;
                  }
                  return null;
                },
              ),

              // 기본 카테고리 안내 메시지
              if (_isDefaultCategory) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsThin.info,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.defaultCategoryNameHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // 아이콘 선택
              Text(
                l10n.selectIcon,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              IconPickerButton(
                selectedIcon: _selectedIcon,
                selectedColor: _selectedColor,
                onIconSelected: (icon) {
                  setState(() => _selectedIcon = icon);
                },
              ),

              const SizedBox(height: 24),

              // 색상 선택
              Text(
                l10n.selectColor,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ColorPicker(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() => _selectedColor = color);
                },
              ),

              const SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveCategory,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 커스텀 카테고리인 경우 이름 중복 체크
      if (!_isDefaultCategory) {
        final name = _nameController.text.trim();
        final isDuplicate = await widget.database.isCategoryNameExistsExcept(
          name,
          widget.category.isIncome,
          widget.category.id,
        );

        if (isDuplicate && mounted) {
          setState(() => _isSaving = false);
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.categoryNameDuplicate),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
      }

      // 카테고리 업데이트
      final updatedCategory = widget.category.copyWith(
        icon: _selectedIcon,
        color: _selectedColor.value,
        customName: _isDefaultCategory
            ? Value(widget.category.customName)
            : Value(_nameController.text.trim()),
      );

      await widget.database.updateCategory(updatedCategory);

      HapticFeedback.mediumImpact();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final l10n = AppLocalizations.of(context);

    // 기본 카테고리는 삭제 불가
    if (_isDefaultCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotDeleteDefaultCategory),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // 해당 카테고리를 사용하는 거래 수 조회
    final transactionCount =
        await widget.database.getTransactionCountByCategory(
      widget.category.id,
    );

    // 카테고리 표시 이름
    final categoryName = CategoryUtils.getCategoryName(
      context,
      widget.category,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => DeleteCategoryDialog(
        categoryName: categoryName,
        transactionCount: transactionCount,
        onConfirm: _deleteCategory,
      ),
    );
  }

  Future<void> _deleteCategory() async {
    setState(() => _isDeleting = true);

    try {
      // 해당 카테고리의 거래를 "기타"로 이동
      await widget.database.moveCategoryTransactionsToOther(
        widget.category.id,
        widget.category.isIncome,
      );

      // 카테고리 soft delete
      await widget.database.softDeleteCategory(widget.category.id);

      HapticFeedback.mediumImpact();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isDeleting = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
