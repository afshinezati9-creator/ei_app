import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';
import 'list_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final data = context.watch<DataProvider>();

    final income = data.getTotalByType('income');
    final expense = data.getTotalByType('expense');
    final saving = data.getTotalByType('saving');
    final balance = income - expense;
    final recent = data.getRecentTransactions(limit: 5);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== کارت موجودی =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'موجودی خالص',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.formatCurrency(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _box('درآمد', currency.formatCurrency(income)),
                      const SizedBox(width: 10),
                      _box('مخارج', currency.formatCurrency(expense)),
                      const SizedBox(width: 10),
                      _box('پس‌انداز', currency.formatCurrency(saving)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== دکمه‌های سریع =====
            Row(
              children: [
                _btn('💸', 'مخارج', () => _goToList(context, 'مخارج', 'expense', true)),
                const SizedBox(width: 10),
                _btn('💵', 'درآمد', () => _goToList(context, 'درآمدها', 'income', false)),
                const SizedBox(width: 10),
                _btn('🎯', 'اهداف', () => _goToList(context, 'اهداف', 'goal', false, isGoal: true)),
                const SizedBox(width: 10),
                _btn('⋯', 'بیشتر', () {}),
              ],
            ),
            const SizedBox(height: 20),

            // ===== لیست اخیر =====
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخرین تراکنش‌ها',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'مشاهده همه',
                  style: TextStyle(color: Color(0xFF6C5CE7)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== لیست =====
            Expanded(
              child: recent.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('هنوز تراکنشی ثبت نشده'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final t = recent[index];
                        final isNeg = t.type == 'expense' || t.type == 'debt' || t.type == 'loan';
                        final sign = isNeg ? '−' : '+';
                        final color = isNeg ? Colors.red.shade400 : Colors.green.shade400;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isNeg ? Icons.arrow_downward : Icons.arrow_upward,
                              color: color,
                            ),
                            title: Text(t.title),
                            subtitle: Text(
                              '${t.date} · ${_typeLabel(t.type)}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            trailing: Text(
                              '$sign ${currency.formatNumber(t.amount)} ${currency.symbol}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      );

  Widget _btn(String icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );

  void _goToList(BuildContext ctx, String title, String type, bool isNeg, {bool isGoal = false}) {
    final data = ctx.read<DataProvider>();
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => ListScreen(
          sectionTitle: title,
          items: data.getTransactionsByType(type),
          isNegative: isNeg,
          isGoal: isGoal,
        ),
      ),
    );
  }

  String _typeLabel(String type) {
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
}