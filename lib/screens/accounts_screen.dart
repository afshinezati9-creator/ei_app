import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/account_balance_summary.dart';
import 'add_account_screen.dart';
import 'package:ei_app/providers/providers.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    final accounts = data.accounts;
    final totalBalance = data.getTotalAccountsBalance();

    final cashBalance = accounts
        .where((a) => a.type == 'cash')
        .fold(0.0, (sum, a) => sum + a.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب‌ها و کارت‌ها'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAccountScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AccountBalanceSummary(
              totalBalance: totalBalance,
              cashBalance: cashBalance,
              accountCount: accounts.length,
            ),
            const SizedBox(height: 16),

            if (accounts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هیچ حسابی ثبت نشده',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'برای افزودن روی دکمه ＋ در بالا کلیک کنید',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  if (accounts.any((a) => a.type == 'bank'))
                    _buildSection(
                      context,
                      '🏦 حساب‌های بانکی',
                      accounts.where((a) => a.type == 'bank').toList(),
                      currency,
                      isDark,
                    ),
                  if (accounts.any((a) => a.type == 'card'))
                    _buildSection(
                      context,
                      '💳 کارت‌ها',
                      accounts.where((a) => a.type == 'card').toList(),
                      currency,
                      isDark,
                    ),
                  if (accounts.any((a) => a.type == 'cash'))
                    _buildSection(
                      context,
                      '💰 نقدی',
                      accounts.where((a) => a.type == 'cash').toList(),
                      currency,
                      isDark,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Account> accounts,
    CurrencyProvider currency,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...accounts.map((acc) => AccountCard(
          account: acc,
          currency: currency,
          isDark: isDark,
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddAccountScreen(account: acc),
              ),
            );
          },
          onDelete: () {
            _showDeleteDialog(context, acc.id, acc.name);
          },
        )),
        const SizedBox(height: 4),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف حساب'),
        content: Text('آیا از حذف حساب "$name" مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final data = context.read<DataProvider>();
              data.deleteAccount(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('حساب "$name" حذف شد')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}