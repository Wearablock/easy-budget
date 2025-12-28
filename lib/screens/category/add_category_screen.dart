import 'package:drift/drift.dart' hide Column;
import 'package:easy_budget/constants/category_colors.dart';
import 'package:easy_budget/constants/category_icons.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/widgets/category_preview.dart';
import 'package:easy_budget/screens/category/widgets/color_picker.dart';
import 'package:easy_budget/screens/category/widgets/icon_picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddCategoryScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;

  const AddCategoryScreen({
    super.key,
    required this.database,
    required this.isIncome,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _selectedIcon;
  late Color _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIcon = CategoryIcons.defaultIcon;
    _selectedColor = CategoryColors.defaultColor;
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
        title: Text(l10n.addCategoryTitle),
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                decoration: InputDecoration(
                  hintText: l10n.categoryNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.categoryNameRequired;
                  }
                  if (value.length > 20) {
                    return l10n.categoryNameTooLong;
                  }
                  return null;
                },
              ),

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

    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    setState(() => _isSaving = true);

    try {
      // 중복 이름 체크
      final isDuplicate = await widget.database.isCategoryNameExists(
        name,
        widget.isIncome,
      );

      if (isDuplicate) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.categoryNameDuplicate),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      // 기타 카테고리 앞에 오도록 sortOrder 계산
      final nextSortOrder = await widget.database.getNextCategorySortOrder(
        widget.isIncome,
      );

      final companion = CategoriesCompanion(
        nameKey: const Value('custom'),
        customName: Value(_nameController.text.trim()),
        icon: Value(_selectedIcon),
        color: Value(_selectedColor.toARGB32()),
        isIncome: Value(widget.isIncome),
        isDefault: const Value(false),
        sortOrder: Value(nextSortOrder),
      );

      await widget.database.insertCategory(companion);

      HapticFeedback.mediumImpact();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryAdded),
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
}
