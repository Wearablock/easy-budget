import 'package:easy_budget/app.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const List<LanguageOption> _languages = [
    LanguageOption(code: 'en', name: 'English', flag: '🇺🇸'),
    LanguageOption(code: 'ko', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'ja', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'zh', name: '简体中文', flag: '🇨🇳'),
    LanguageOption(code: 'zh_Hant', name: '繁體中文', flag: '🇹🇼'),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'pt', name: 'Português', flag: '🇧🇷'),
    LanguageOption(code: 'it', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    LanguageOption(code: 'th', name: 'ภาษาไทย', flag: '🇹🇭'),
    LanguageOption(code: 'vi', name: 'Tiếng Việt', flag: '🇻🇳'),
    LanguageOption(code: 'id', name: 'Bahasa Indonesia', flag: '🇮🇩'),
  ];

  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = PreferencesService.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: ListView(
        children: [
          // 시스템 기본값 옵션
          _buildLanguageTile(
            context,
            code: null,
            name: l10n.systemDefault,
            flag: '🌐',
            isSelected: _selectedCode == null,
          ),
          const Divider(),
          ..._languages.map(
            (lang) => _buildLanguageTile(
              context,
              code: lang.code,
              name: lang.name,
              flag: lang.flag,
              isSelected: _selectedCode == lang.code,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String? code,
    required String name,
    required String flag,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(name),
      trailing: isSelected
          ? Icon(
              PhosphorIconsFill.checkCircle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedCode = code;
        });
        _changeLanguage(code);
      },
    );
  }

  void _changeLanguage(String? code) {
    Locale? locale;
    if (code != null) {
      if (code == 'zh_Hant') {
        locale = const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
        );
      } else {
        locale = Locale(code);
      }
    }
    EasyBudgetApp.setLocale(locale);
    Navigator.of(context).pop(true);
  }
}
