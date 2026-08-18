import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/notification_banner.dart'; // ✅ اضافه شد
import 'list_screen.dart';
import 'add_transaction_screen.dart';
import 'goals_screen.dart';
import 'package:ei_app/providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final dateProvider = context.watch<DateProvider>();
    final isDark = theme.isDarkMode(context);

    final income = data.getTotalByType('income');
    final expense = data.getTotalByType('expense');
    final saving = data.getTotalByType('saving');
    final balance = income - expense;
    final recent = data.getRecentTransactions(limit: 5);

    final activeGoals = data.getActiveGoals();
    final displayGoals = activeGoals.take(3).toList();
    final totalGoals = activeGoals.length;

    final goals = data.goals.fold(0.0, (sum, g) => sum + g.currentAmount);
    final debts = data.getTotalByType('debt') + data.getTotalByType('loan');
    final totalAccounts = data.getTotalAccountsBalance();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const NotificationBanner(), // ✅ اضافه شد
            BalanceCard(
              balance: balance,
              income: income,
              expense: expense,
              saving: saving,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _quickButton('💸', 'مخارج', () => _goTo(context, 'expenses')),
                const SizedBox(width: 8),
                _quickButton('💵', 'درآمد', () => _goTo(context, 'incomes')),
                const SizedBox(width: 8),
                _quickButton('🎯', 'اهداف', () => _goTo(context, 'goals')),
                const SizedBox(width: 8),
                _quickButton('📋', 'برنامه', () => _goTo(context, 'planning')),
              ],
            ),
            const SizedBox(height: 16),

            if (displayGoals.isNotEmpty)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag, size: 18, color: Color(0xFF6C5CE7)),
                            const SizedBox(width: 6),
                            Text(
                              'اهداف فعال',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalGoals',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7)),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _goTo(context, 'goals'),
                          child: const Text(
                            'مشاهده همه',
                            style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...displayGoals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GoalCard(goal: goal),
                    )),
                    if (displayGoals.length < totalGoals)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'و ${totalGoals - displayGoals.length} هدف دیگر...',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            if (displayGoals.isNotEmpty) const SizedBox(height: 16),

            Row(
              children: [
                _summaryBox('اهداف', currency.formatCurrency(goals), Colors.orange),
                const SizedBox(width: 6),
                _summaryBox('پس‌انداز', currency.formatCurrency(saving), Colors.blue),
                const SizedBox(width: 6),
                _summaryBox('قرض+وام', currency.formatCurrency(debts), Colors.red),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مجموع موجودی حساب‌ها',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    currency.formatCurrency(totalAccounts),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخرین تراکنش‌ها',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => _goTo(context, 'expenses'),
                  child: const Text(
                    'مشاهده همه',
                    style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (recent.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('هنوز تراکنشی ثبت نشده', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              )
            else
              ...recent.map((t) => _buildTransactionItem(t, currency, dateProvider, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(String icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    dynamic t,
    CurrencyProvider currency,
    DateProvider dateProvider,
    bool isDark,
  ) {
    final isNeg = t.type == 'expense' || t.type == 'debt' || t.type == 'loan';
    final sign = isNeg ? '−' : '+';
    final color = isNeg ? Colors.red.shade400 : Colors.green.shade400;
    final typeLabel = _getTypeLabel(t.type);

    final displayDate = dateProvider.convertDate(t.date, dateProvider.currentFormat);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isNeg ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '$displayDate · $typeLabel${t.categoryName.isNotEmpty ? ' · ${t.categoryName}' : ''}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
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
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'income':
        return 'درآمد';
      case 'expense':
        return 'مخارج';
      case 'saving':
        return 'پس‌انداز';
      case 'goal':
        return 'هدف';
      case 'loan':
        return 'وام';
      case 'debt':
        return 'قرض';
      case 'credit':
        return 'طلبکاری';
      default:
        return type;
    }
  }

  void _goTo(BuildContext context, String page) {
    if (page == 'expenses' || page == 'incomes' || page == 'goals') {
      if (page == 'goals') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListScreen(
            sectionTitle: page == 'expenses' ? 'مخارج' : 'درآمدها',
            items: page == 'expenses'
                ? context.read<DataProvider>().getTransactionsByType('expense')
                : context.read<DataProvider>().getTransactionsByType('income'),
            isNegative: page == 'expenses',
            isGoal: false,
          ),
        ),
      );
    } else if (page == 'planning') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صفحه برنامه‌ریزی در حال ساخت')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$page در حال ساخت')),
      );
    }
  }
}