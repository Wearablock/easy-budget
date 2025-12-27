import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/daily_transaction_group.dart';
import 'package:easy_budget/models/transaction_filter.dart';
import 'package:easy_budget/models/transaction_view_mode.dart';
import 'package:easy_budget/screens/transaction/add_transaction_screen.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:easy_budget/utils/transaction_grouper.dart';
import 'package:easy_budget/widgets/dismissible_transaction_tile.dart';
import 'package:easy_budget/widgets/empty_transaction_state.dart';
import 'package:easy_budget/widgets/transaction_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class TransactionListScreen extends StatefulWidget {
  final AppDatabase database;
  final int initialYear;
  final int initialMonth;

  const TransactionListScreen({
    super.key,
    required this.database,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late int _year;
  late int _month;
  TransactionViewMode _viewMode = TransactionViewMode.list;
  DateTime? _selectedDate;
  late DateTime _focusedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  TransactionFilter _filter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    _focusedDay = DateTime(_year, _month); // Phase 4-2: focusedDay 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<Transaction>>(
        stream: widget.database.watchTransactionsByMonth(_year, _month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          final filteredTransactions = _filter.apply(transactions);
          final groups = TransactionGrouper.groupByDate(filteredTransactions);

          return Column(
            children: [
              _buildFilterSegment(context),

              const Divider(height: 1),

              Expanded(
                child: _viewMode == TransactionViewMode.list
                    ? _buildListView(context, groups)
                    : _buildCalendarView(context, groups),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(PhosphorIconsThin.arrowLeft),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _buildMonthSelector(context),
      actions: [
        // 뷰 모드 토글 버튼
        IconButton(
          icon: Icon(
            _viewMode == TransactionViewMode.list
                ? PhosphorIconsThin.calendarBlank
                : PhosphorIconsThin.list,
          ),
          onPressed: _toggleViewMode,
          tooltip: _viewMode == TransactionViewMode.list
              ? 'Calendar View'
              : 'List View',
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMM(locale);
    final date = DateTime(_year, _month);

    return GestureDetector(
      onTap: () => _showMonthPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(PhosphorIconsThin.caretLeft, size: 20),
            onPressed: _previousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(date),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(PhosphorIconsThin.caretRight, size: 20),
            onPressed: _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == TransactionViewMode.list
          ? TransactionViewMode.calendar
          : TransactionViewMode.list;
      _selectedDate = null; // 뷰 전환 시 선택 초기화
    });
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
      _focusedDay = DateTime(_year, _month); // Phase 4-2: focusedDay 동기화
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
      _focusedDay = DateTime(_year, _month); // Phase 4-2: focusedDay 동기화
      _selectedDate = null;
    });
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_year, _month),
      firstDate: DateTime(DateTime.now().year - 5, 1, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _year = picked.year;
        _month = picked.month;
        _focusedDay = DateTime(_year, _month); // Phase 4-2: focusedDay 동기화
        _selectedDate = null;
      });
    }
  }

  // ==================== 리스트 뷰 ====================

  Widget _buildListView(
    BuildContext context,
    List<DailyTransactionGroup> groups,
  ) {
    if (groups.isEmpty) {
      return const EmptyTransactionState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildDateGroup(context, group);
      },
    );
  }

  Widget _buildDateGroup(BuildContext context, DailyTransactionGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더
        _buildDateHeader(context, group),

        // 해당 날짜의 거래 목록
        ...group.transactions.map(
          (transaction) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DismissibleTransactionTile(
              transaction: transaction,
              database: widget.database,
              onTap: () => _openEditTransaction(context, transaction),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, DailyTransactionGroup group) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    final dateFormat = DateFormat.MMMEd(locale);
    final formattedDate = dateFormat.format(group.date);

    int displayAmount = 0;
    if (_filter == TransactionFilter.all) {
      displayAmount = group.netAmount;
    } else if (_filter == TransactionFilter.income) {
      displayAmount = group.totalIncome;
    } else {
      displayAmount = -group.totalExpense; // 지출은 음수로 표시
    }
    final isPositive = displayAmount >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${CurrencyUtils.formatWithSymbol(displayAmount.abs())}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isPositive ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 캘린더 뷰 ====================

  Widget _buildCalendarView(
    BuildContext context,
    List<DailyTransactionGroup> groups,
  ) {
    // 선택된 날짜의 그룹 조회
    final selectedGroup = _selectedDate != null
        ? TransactionGrouper.getGroupForDate(groups, _selectedDate!)
        : null;

    return Column(
      children: [
        _buildTableCalendar(context, groups),

        const Divider(height: 1),

        // 선택된 날짜 헤더
        _buildSelectedDateHeader(context, selectedGroup),

        // 선택된 날짜의 거래 목록
        Expanded(child: _buildSelectedDateTransactions(context, groups)),
      ],
    );
  }

  Widget _buildSelectedDateHeader(
    BuildContext context,
    DailyTransactionGroup? group,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    if (_selectedDate == null) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat.MMMEd(locale);
    final formattedDate = dateFormat.format(_selectedDate!);

    int displayIncome = 0;
    int displayExpense = 0;

    if (group != null) {
      if (_filter != TransactionFilter.expense) {
        displayIncome = group.totalIncome;
      }
      if (_filter != TransactionFilter.income) {
        displayExpense = group.totalExpense;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (group != null)
            Row(
              children: [
                if (displayIncome > 0) ...[
                  Text(
                    '+${CurrencyUtils.formatWithSymbol(displayIncome)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.income,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (displayExpense > 0)
                  Text(
                    '-${CurrencyUtils.formatWithSymbol(displayExpense)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar(
    BuildContext context,
    List<DailyTransactionGroup> groups,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final eventDays = _buildEventMap(groups);

    return TableCalendar(
      firstDay: DateTime(DateTime.now().year - 5, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      locale: locale,

      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;
        });
      },

      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _year = focusedDay.year;
          _month = focusedDay.month;
          _selectedDate = null;
        });
      },

      eventLoader: (day) {
        final dateOnly = DateTime(day.year, day.month, day.day);
        return eventDays[dateOnly] ?? [];
      },

      calendarStyle: _buildCalendarStyle(theme),
      headerStyle: _buildHeaderStyle(theme),
      daysOfWeekStyle: _buildDaysOfWeekStyle(theme),

      calendarBuilders: _buildCalendarBuilders(theme),
    );
  }

  /// 거래가 있는 날짜의 이벤트 맵 생성
  Map<DateTime, List<DailyTransactionGroup>> _buildEventMap(
    List<DailyTransactionGroup> groups,
  ) {
    final Map<DateTime, List<DailyTransactionGroup>> eventMap = {};

    for (final group in groups) {
      final dateOnly = DateTime(
        group.date.year,
        group.date.month,
        group.date.day,
      );
      eventMap[dateOnly] = [group];
    }

    return eventMap;
  }

  Widget _buildSelectedDateTransactions(
    BuildContext context,
    List<DailyTransactionGroup> groups,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_selectedDate == null) {
      return Center(
        child: Text(
          l10n.selectDateToView,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    final group = TransactionGrouper.getGroupForDate(groups, _selectedDate!);

    if (group == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsThin.receipt,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTransactionsOnDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.transactions.length,
      itemBuilder: (context, index) {
        final transaction = group.transactions[index];
        return DismissibleTransactionTile(
          transaction: transaction,
          database: widget.database,
          onTap: () => _openEditTransaction(context, transaction),
        );
      },
    );
  }

  CalendarStyle _buildCalendarStyle(ThemeData theme) {
    return CalendarStyle(
      // 기본 텍스트 스타일
      defaultTextStyle: theme.textTheme.bodyMedium!,
      weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.error.withValues(alpha: 0.7),
      ),
      outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.outline.withValues(alpha: 0.5),
      ),

      // 오늘 날짜
      todayDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        shape: BoxShape.circle,
      ),
      todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),

      // 선택된 날짜
      selectedDecoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w600,
      ),

      // 마커 스타일
      markerDecoration: const BoxDecoration(shape: BoxShape.circle),
      markersMaxCount: 2,
      markerSize: 6,
      markerMargin: const EdgeInsets.symmetric(horizontal: 1),

      // 셀 정렬
      cellAlignment: Alignment.center,
      cellMargin: const EdgeInsets.all(4),
    );
  }

  HeaderStyle _buildHeaderStyle(ThemeData theme) {
    return HeaderStyle(
      // 헤더 포맷
      formatButtonVisible: false, // 포맷 버튼 숨김
      titleCentered: true,

      // 타이틀 스타일
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),

      // 네비게이션 아이콘
      leftChevronIcon: Icon(
        PhosphorIconsThin.caretLeft,
        color: theme.colorScheme.onSurface,
      ),
      rightChevronIcon: Icon(
        PhosphorIconsThin.caretRight,
        color: theme.colorScheme.onSurface,
      ),

      // 헤더 패딩
      headerPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle(ThemeData theme) {
    return DaysOfWeekStyle(
      weekdayStyle: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.outline,
        fontWeight: FontWeight.w500,
      ),
      weekendStyle: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.error.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  CalendarBuilders _buildCalendarBuilders(ThemeData theme) {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        if (events.isEmpty) return null;

        final group = events.first as DailyTransactionGroup;
        final hasIncome = group.totalIncome > 0;
        final hasExpense = group.totalExpense > 0;

        final showIncome = _filter != TransactionFilter.expense && hasIncome;
        final showExpense = _filter != TransactionFilter.income && hasExpense;

        return Positioned(
          bottom: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIncome)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.income,
                    shape: BoxShape.circle,
                  ),
                ),
              if (showExpense)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.expense,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },

      // 선택된 날짜의 순수익 표시 (선택적)
      selectedBuilder: (context, date, focusedDay) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  // ==================== 공통 ====================

  Widget _buildFilterSegment(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            TransactionFilterChip(
              label: l10n.all,
              icon: PhosphorIconsBold.listBullets,
              isSelected: _filter == TransactionFilter.all,
              onTap: () => setState(() {
                _filter = TransactionFilter.all;
                _selectedDate = null;
              }),
            ),
            TransactionFilterChip(
              label: l10n.income,
              icon: PhosphorIconsBold.arrowDown,
              isSelected: _filter == TransactionFilter.income,
              activeColor: AppColors.income,
              onTap: () => setState(() {
                _filter = TransactionFilter.income;
                _selectedDate = null;
              }),
            ),
            TransactionFilterChip(
              label: l10n.expense,
              icon: PhosphorIconsBold.arrowUp,
              isSelected: _filter == TransactionFilter.expense,
              activeColor: AppColors.expense,
              onTap: () => setState(() {
                _filter = TransactionFilter.expense;
                _selectedDate = null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditTransaction(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          database: widget.database,
          existingTransaction: transaction,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
