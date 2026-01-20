import 'package:easy_budget/app.dart';
import 'package:easy_budget/constants/app_spacing.dart';
import 'package:easy_budget/constants/app_urls.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/category/category_list_screen.dart';
import 'package:easy_budget/screens/settings/language_selection_screen.dart';
import 'package:easy_budget/screens/settings/currency_settings_screen.dart';
import 'package:easy_budget/screens/settings/webview_screen.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase database;

  const SettingsScreen({super.key, required this.database});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // 일반 섹션
          _buildSectionHeader(context, l10n.general),
          _buildLanguageTile(context, l10n),
          _buildCurrencyTile(context, l10n),
          _buildCategoryManagementTile(context, l10n),

          const SizedBox(height: 8),

          // 화면 섹션
          _buildSectionHeader(context, l10n.appearance),
          _buildThemeTile(context, l10n),

          const SizedBox(height: 8),

          // 약관 및 정책 섹션
          _buildSectionHeader(context, l10n.termsAndPolicies),
          _buildLinkTile(
            context,
            icon: PhosphorIconsThin.fileText,
            title: l10n.termsOfService,
            onTap: () => _openWebView(context, l10n.termsOfService, AppUrls.termsUrl),
          ),
          _buildLinkTile(
            context,
            icon: PhosphorIconsThin.shieldCheck,
            title: l10n.privacyPolicy,
            onTap: () => _openWebView(context, l10n.privacyPolicy, AppUrls.privacyUrl),
          ),
          _buildLinkTile(
            context,
            icon: PhosphorIconsThin.headset,
            title: l10n.support,
            onTap: () => _openWebView(context, l10n.support, AppUrls.supportUrl),
          ),

          const SizedBox(height: 8),

          // 정보 섹션
          _buildSectionHeader(context, l10n.about),
          _buildVersionTile(context, l10n),

          const SizedBox(height: 24),
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

  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    final currentLocale = Localizations.localeOf(context);
    final languageName = _getLanguageName(currentLocale.languageCode, l10n);

    return ListTile(
      leading: _buildIconContainer(context, PhosphorIconsThin.globe),
      title: Text(l10n.language),
      subtitle: Text(languageName),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: () => _openLanguageSelection(context),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, AppLocalizations l10n) {
    final currency = CurrencyUtils.currentCurrency;
    final currencyName = _getCurrencyName(currency.code, l10n);

    return ListTile(
      leading:
          _buildIconContainer(context, PhosphorIconsThin.currencyCircleDollar),
      title: Text(l10n.currency),
      subtitle: Text('${currency.symbol} - $currencyName'),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: () => _openCurrencySelection(context),
    );
  }

  Widget _buildCategoryManagementTile(
      BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: _buildIconContainer(context, PhosphorIconsThin.squaresFour),
      title: Text(l10n.categoryManagement),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: () => _openCategoryManagement(context),
    );
  }

  Widget _buildThemeTile(BuildContext context, AppLocalizations l10n) {
    final themeMode = PreferencesService.themeMode;
    final themeName = _getThemeName(themeMode, l10n);

    return ListTile(
      leading: _buildIconContainer(
        context,
        themeMode == ThemeMode.dark
            ? PhosphorIconsThin.moon
            : themeMode == ThemeMode.light
                ? PhosphorIconsThin.sun
                : PhosphorIconsThin.circleHalf,
      ),
      title: Text(l10n.appearance),
      subtitle: Text(themeName),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: () => _showThemeDialog(context, l10n),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _buildIconContainer(context, icon),
      title: Text(title),
      trailing: const Icon(PhosphorIconsThin.caretRight),
      onTap: onTap,
    );
  }

  Widget _buildVersionTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: _buildIconContainer(context, PhosphorIconsThin.info),
      title: Text(l10n.version),
      subtitle: const Text('1.0.0'),
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon) {
    return Container(
      width: AppSpacing.iconContainerSm,
      height: AppSpacing.iconContainerSm,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'ko':
        return l10n.languageKorean;
      case 'ja':
        return l10n.languageJapanese;
      case 'zh':
        return l10n.languageChinese;
      case 'de':
        return l10n.languageGerman;
      case 'fr':
        return l10n.languageFrench;
      case 'es':
        return l10n.languageSpanish;
      case 'pt':
        return l10n.languagePortuguese;
      case 'it':
        return l10n.languageItalian;
      case 'ru':
        return l10n.languageRussian;
      case 'ar':
        return l10n.languageArabic;
      case 'th':
        return l10n.languageThai;
      case 'vi':
        return l10n.languageVietnamese;
      case 'id':
        return l10n.languageIndonesian;
      default:
        return l10n.languageEnglish;
    }
  }

  String _getCurrencyName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'JPY':
        return l10n.currencyJPY;
      case 'KRW':
        return l10n.currencyKRW;
      case 'CNY':
        return l10n.currencyCNY;
      case 'TWD':
        return l10n.currencyTWD;
      case 'HKD':
        return l10n.currencyHKD;
      case 'INR':
        return l10n.currencyINR;
      case 'VND':
        return l10n.currencyVND;
      case 'THB':
        return l10n.currencyTHB;
      case 'IDR':
        return l10n.currencyIDR;
      case 'MXN':
        return l10n.currencyMXN;
      case 'BRL':
        return l10n.currencyBRL;
      case 'CHF':
        return l10n.currencyCHF;
      case 'RUB':
        return l10n.currencyRUB;
      case 'SAR':
        return l10n.currencySAR;
      default:
        return code;
    }
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  void _openLanguageSelection(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const LanguageSelectionScreen(),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _openCurrencySelection(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CurrencySettingsScreen(),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _openCategoryManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryListScreen(database: widget.database),
      ),
    );
  }

  void _openWebView(BuildContext context, String title, String url) {
    // 현재 언어 코드를 URL 파라미터로 추가
    final langCode = PreferencesService.languageCode;
    String? htmlLangCode;
    if (langCode != null) {
      // HTML에서는 zh-TW 형식 사용
      htmlLangCode = langCode == 'zh_Hant' ? 'zh-TW' : langCode;
    } else {
      // 시스템 기본값일 경우 현재 locale 사용
      final locale = Localizations.localeOf(context);
      if (locale.scriptCode == 'Hant') {
        htmlLangCode = 'zh-TW';
      } else {
        htmlLangCode = locale.languageCode;
      }
    }
    final urlWithLang = '$url?lang=$htmlLangCode';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(title: title, url: urlWithLang),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    final currentMode = PreferencesService.themeMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appearance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              l10n.systemTheme,
              ThemeMode.system,
              currentMode,
              PhosphorIconsThin.circleHalf,
            ),
            _buildThemeOption(
              context,
              l10n.lightMode,
              ThemeMode.light,
              currentMode,
              PhosphorIconsThin.sun,
            ),
            _buildThemeOption(
              context,
              l10n.darkMode,
              ThemeMode.dark,
              currentMode,
              PhosphorIconsThin.moon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
    IconData icon,
  ) {
    final isSelected = mode == currentMode;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              PhosphorIconsFill.checkCircle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        EasyBudgetApp.setThemeMode(mode);
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}
