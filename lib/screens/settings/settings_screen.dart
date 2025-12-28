import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/category_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsScreen extends StatelessWidget {
  final AppDatabase database;

  const SettingsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'General'),
          _buildCategoryManagementTile(context, l10n),
          const Divider(),
          // 추후 다른 설정 메뉴 추가
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCategoryManagementTile(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          PhosphorIconsThin.squaresFour,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(l10n.categoryManagement),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: () => _openCategoryManagement(context),
    );
  }

  void _openCategoryManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryListScreen(database: database),
      ),
    );
  }
}
