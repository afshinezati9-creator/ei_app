import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();

    final savings = data.getTransactionsByType('saving');
    final loans = data.getTransactionsByType('loan');
    final debts = data.getTransactionsByType('debt');
    final credits = data.getTransactionsByType('credit');

    return Scaffold(
      appBar: AppBar(
        title: const Text('بیشتر'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _menuItem(
              context,
              icon: Icons.savings,
              title: 'پس‌اندازها',
              count: savings.length,
              color: Colors.blue,
              onTap: () {
                _showMessage(context, 'پس‌اندازها: ${savings.length} مورد');
              },
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.account_balance,
              title: 'وام‌ها',
              count: loans.length,
              color: Colors.purple,
              onTap: () {
                _showMessage(context, 'وام‌ها: ${loans.length} مورد');
              },
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.money_off,
              title: 'قرض‌ها',
              count: debts.length,
              color: Colors.deepOrange,
              onTap: () {
                _showMessage(context, 'قرض‌ها: ${debts.length} مورد');
              },
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.payment,
              title: 'طلبکاری‌ها',
              count: credits.length,
              color: Colors.teal,
              onTap: () {
                _showMessage(context, 'طلبکاری‌ها: ${credits.length} مورد');
              },
            ),
            const SizedBox(height: 16),
            _menuItem(
              context,
              icon: Icons.currency_exchange,
              title: 'انتخاب ارز (${currency.symbol})',
              count: null,
              color: Colors.orange,
              onTap: () => _showCurrencyDialog(context, currency),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.delete_outline,
              title: 'پاک کردن همه داده‌ها',
              count: null,
              color: Colors.red,
              onTap: () => _showClearDialog(context, data),
            ),
            const SizedBox(height: 16),
            _menuItem(
              context,
              icon: Icons.info_outline,
              title: 'درباره ei',
              count: null,
              color: Colors.grey,
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    int? count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            if (count != null) Text('$count مورد', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCurrencyDialog(BuildContext context, CurrencyProvider currency) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('انتخاب ارز'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currency.currencies.map((c) {
            return RadioListTile<String>(
              title: Text(c),
              value: c,
              groupValue: currency.symbol,
              onChanged: (v) {
                if (v != null) currency.setCurrency(v);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, DataProvider data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پاک کردن داده‌ها'),
        content: const Text('آیا از پاک کردن همه تراکنش‌ها مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              data.clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('همه داده‌ها پاک شد')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('درباره ei'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نسخه ۱.۰.۰'),
            SizedBox(height: 8),
            Text('حسابدار شخصی پیشرفته'),
            SizedBox(height: 8),
            Text('ساخته شده با ❤️'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
        ],
      ),
    );
  }
}