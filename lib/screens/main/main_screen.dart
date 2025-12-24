import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/screens/home/home_screen.dart';
import 'package:easy_budget/screens/settings/settings_screen.dart';
import 'package:easy_budget/screens/statistics/statistics_screen.dart';
import 'package:easy_budget/screens/transaction/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late AppDatabase _db;

  // 각 탭의 화면들
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _screens = [
      HomeScreen(database: _db),
      StatisticsScreen(database: _db),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  bool get _showFab => _currentIndex != 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _showFab ? _buildFab(context) : null,
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openAddTransaction(context),
      tooltip: '거래 추가',
      child: const Icon(PhosphorIconsThin.plus),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(database: _db),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIconsThin.house),
          activeIcon: Icon(PhosphorIconsFill.house),
          label: '홈', // TODO: l10n
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIconsThin.chartBar),
          activeIcon: Icon(PhosphorIconsFill.chartBar),
          label: '통계', // TODO: l10n
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIconsThin.gear),
          activeIcon: Icon(PhosphorIconsFill.gear),
          label: '설정', // TODO: l10n
        ),
      ],
    );
  }
}
