// ============================================================
// مسیر: lib/screens/stats_screen.dart (اصلاح - اضافه کردن متدهای گمشده)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/chart_widget.dart';
import '../widgets/date_range_picker.dart';
import 'package:ei_app/providers/providers.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with AutomaticKeepAliveClientMixin {
  String _rangeFrom = '';
  String _rangeTo = '';
  String _rangeType = 'month';
  String _selectedChartType = 'pie';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateProvider = context.read<DateProvider>();
      final defaultRange = dateProvider.getDefaultRange('month');
      setState(() {
        _rangeFrom = defaultRange['from'] ?? '';
        _rangeTo = defaultRange['to'] ?? '';
        _rangeType = 'month';
      });
    });
  }

  void _onRangeSelected(String from, String to, String rangeType) {
    if (!mounted) return;
    setState(() {
      _rangeFrom = from;
      _rangeTo = to;
      _rangeType = rangeType;
    });
    final dateProvider = context.read<DateProvider>();
    dateProvider.setDateRange(from, to, rangeType: rangeType);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    final allTransactions = _getTransactionsInRange(data);

    final income = allTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final expense = allTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);
    final saving = allTransactions
        .where((t) => t.type == 'saving')
        .fold(0.0, (s, t) => s + t.amount);
    final debt = allTransactions
        .where((t) => t.type == 'debt' || t.type == 'loan')
        .fold(0.0, (s, t) => s + t.amount);
    final goals = allTransactions
        .where((t) => t.type == 'goal')
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    final categoryData = <String, double>{};
    for (var t in allTransactions.where((t) => t.type == 'expense')) {
      final key = t.categoryName.isNotEmpty ? t.categoryName : 'متفرقه';
      categoryData[key] = (categoryData[key] ?? 0) + t.amount;
    }

    final typeData = {
      'درآمد': income,
      'مخارج': expense,
      'پس‌انداز': saving,
      'قرض+وام': debt,
      'اهداف': goals,
    };

    final hasGap = expense > income && income > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('آمار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_selectedChartType == 'pie' ? Icons.bar_chart : Icons.pie_chart),
            onPressed: () {
              setState(() {
                _selectedChartType = _selectedChartType == 'pie' ? 'bar' : 'pie';
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DateRangePicker(
              onRangeSelected: _onRangeSelected,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'خلاصه مالی',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statBox('موجودی', currency.formatCurrency(balance), balance >= 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      _statBox('درآمد', currency.formatCurrency(income), Colors.green),
                      const SizedBox(width: 6),
                      _statBox('مخارج', currency.formatCurrency(expense), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statBox('پس‌انداز', currency.formatCurrency(saving), Colors.blue),
                      const SizedBox(width: 6),
                      _statBox('قرض+وام', currency.formatCurrency(debt), Colors.orange),
                      const SizedBox(width: 6),
                      _statBox('اهداف', currency.formatCurrency(goals), Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('تعداد تراکنش‌ها: '),
                        Text(
                          allTransactions.length.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (hasGap)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ هشدار: گپ مالی! مخارج (${currency.formatCurrency(expense)}) از درآمد (${currency.formatCurrency(income)}) بیشتر شده است.',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            if (categoryData.isNotEmpty)
              ChartWidget(
                data: categoryData,
                title: 'دسته‌بندی مخارج',
                type: _selectedChartType == 'pie' ? ChartType.pie : ChartType.bar,
              ),
            const SizedBox(height: 12),

            if (typeData.values.any((v) => v > 0))
              ChartWidget(
                data: typeData,
                title: 'نوع تراکنش‌ها',
                type: _selectedChartType == 'pie' ? ChartType.pie : ChartType.bar,
              ),
            const SizedBox(height: 12),

            if (allTransactions.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تراکنش‌های این بازه',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allTransactions.length > 5 ? 5 : allTransactions.length,
                        itemBuilder: (context, index) {
                          final t = allTransactions[index];
                          return _buildTransactionItem(t, currency);
                        },
                      ),
                    ),
                    if (allTransactions.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'و ${allTransactions.length - 5} تراکنش دیگر...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getTransactionsInRange(DataProvider data) {
    final all = data.transactions;
    if (_rangeFrom.isNotEmpty && _rangeTo.isNotEmpty) {
      final fromInt = _dateToInt(_rangeFrom);
      final toInt = _dateToInt(_rangeTo);
      return all.where((t) {
        final dateInt = _dateToInt(t.date);
        return dateInt >= fromInt && dateInt <= toInt;
      }).toList();
    }
    return all;
  }

  int _dateToInt(String date) {
    final parts = date.split('/');
    if (parts.length != 3) return 0;
    return int.parse(parts[0]) * 10000 + int.parse(parts[1]) * 100 + int.parse(parts[2]);
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(dynamic t, CurrencyProvider currency) {
    final displayDate = t.date;

    final isNeg = t.type == 'expense' || t.type == 'debt' || t.type == 'loan';
    final sign = isNeg ? '−' : '+';
    final color = isNeg ? Colors.red.shade400 : Colors.green.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$displayDate · ${t.categoryName}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${currency.formatNumber(t.amount)} ${currency.symbol}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}