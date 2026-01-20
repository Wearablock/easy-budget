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
  // 현재 지원하는 언어만 표시 (en, ko, ja, zh, zh_TW)
  // 추후 다른 언어 추가 시 여기에 추가
  static const List<LanguageOption> _supportedLanguages = [
    LanguageOption(code: 'en', name: 'English', flag: '🇺🇸'),
    LanguageOption(code: 'ko', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'ja', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'zh', name: '简体中文', flag: '🇨🇳'),
    LanguageOption(code: 'zh_Hant', name: '繁體中文', flag: '🇹🇼'),
  ];

  // 추후 지원 예정 언어
  static const List<LanguageOption> _comingSoonLanguages = [
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

          // 지원 언어
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Supported',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ..._supportedLanguages.map(
            (lang) => _buildLanguageTile(
              context,
              code: lang.code,
              name: lang.name,
              flag: lang.flag,
              isSelected: _selectedCode == lang.code,
            ),
          ),

          // 추후 지원 예정 언어 (비활성화)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          ..._comingSoonLanguages.map(
            (lang) => _buildLanguageTile(
              context,
              code: lang.code,
              name: lang.name,
              flag: lang.flag,
              isSelected: false,
              enabled: false,
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
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Text(
        flag,
        style: TextStyle(
          fontSize: 24,
          color: enabled ? null : Theme.of(context).disabledColor,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: enabled ? null : Theme.of(context).disabledColor,
        ),
      ),
      trailing: isSelected
          ? Icon(
              PhosphorIconsFill.checkCircle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: enabled
          ? () {
              setState(() {
                _selectedCode = code;
              });
              _changeLanguage(code);
            }
          : null,
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
