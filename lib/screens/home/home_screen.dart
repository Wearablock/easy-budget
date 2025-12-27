import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/screens/home/widgets/month_selector.dart';
import 'package:easy_budget/screens/home/widgets/monthly_summary_card.dart';
import 'package:easy_budget/screens/home/widgets/recent_transactions.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;

  const HomeScreen({super.key, required this.database});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Easy Budget'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 월 선택기
            MonthSelector(
              selectedMonth: _selectedMonth,
              onMonthChanged: _onMonthChanged,
            ),

            // 월별 요약 카드
            MonthlySummaryCard(
              database: widget.database,
              year: _selectedMonth.year,
              month: _selectedMonth.month,
            ),

            // 최근 거래 목록
            Expanded(
              child: RecentTransactions(
                database: widget.database,
                year: _selectedMonth.year,
                month: _selectedMonth.month,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
