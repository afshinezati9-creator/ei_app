import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'settings_screen.dart';
import 'accounts_screen.dart';
import 'list_screen.dart';
import 'notes_screen.dart';
import 'goals_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = context.watch<ThemeProvider>();
    final notification = context.watch<NotificationProvider>();
    final isDark = theme.isDarkMode(context);

    final savingsCount = data.getTransactionsByType('saving').length;
    final loansCount = data.getTransactionsByType('loan').length;
    final debtsCount = data.getTransactionsByType('debt').length;
    final creditsCount = data.getTransactionsByType('credit').length;
    final goalsCount = data.goals.length;
    final notesCount = data.notes.length;
    final accountsCount = data.accounts.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بیشتر'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickStat('🏦', 'حساب‌ها', accountsCount),
                  _quickStat('🎯', 'اهداف', goalsCount),
                  _quickStat('📝', 'یادداشت', notesCount),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '📊 مدیریت مالی',
              isDark: isDark,
              children: [
                _menuItem(
                  icon: Icons.savings,
                  title: 'پس‌اندازها',
                  subtitle: '$savingsCount مورد',
                  color: Colors.blue,
                  onTap: () => _navigateToType(context, 'پس‌اندازها', 'saving', false),
                ),
                _menuItem(
                  icon: Icons.account_balance,
                  title: 'وام‌ها',
                  subtitle: '$loansCount مورد',
                  color: Colors.purple,
                  onTap: () => _navigateToType(context, 'وام‌ها', 'loan', true),
                ),
                _menuItem(
                  icon: Icons.money_off,
                  title: 'قرض‌ها',
                  subtitle: '$debtsCount مورد',
                  color: Colors.deepOrange,
                  onTap: () => _navigateToType(context, 'قرض‌ها', 'debt', true),
                ),
                _menuItem(
                  icon: Icons.payment,
                  title: 'طلبکاری‌ها',
                  subtitle: '$creditsCount مورد',
                  color: Colors.teal,
                  onTap: () => _navigateToType(context, 'طلبکاری‌ها', 'credit', false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: '📋 برنامه‌ریزی',
              isDark: isDark,
              children: [
                _menuItem(
                  icon: Icons.flag,
                  title: 'اهداف',
                  subtitle: '$goalsCount هدف',
                  color: Colors.orange,
                  onTap: () => _navigateToGoals(context),
                ),
                _menuItem(
                  icon: Icons.note_alt,
                  title: 'یادداشت‌ها',
                  subtitle: '$notesCount یادداشت',
                  color: Colors.blueGrey,
                  onTap: () => _navigateToNotes(context),
                ),
                _menuItem(
                  icon: Icons.notifications,
                  title: 'اعلان‌ها',
                  subtitle: 'مدیریت یادآوری‌ها',
                  color: Colors.deepOrange,
                  onTap: () => _navigateToNotifications(context),
                  badgeCount: notification.activeCount,
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: '⚙️ تنظیمات',
              isDark: isDark,
              children: [
                _menuItem(
                  icon: Icons.account_balance_outlined,
                  title: 'حساب‌ها و کارت‌ها',
                  subtitle: '$accountsCount حساب',
                  color: const Color(0xFF0984E3),
                  onTap: () => _navigateToAccounts(context),
                ),
                _menuItem(
                  icon: Icons.settings,
                  title: 'تنظیمات',
                  subtitle: 'امنیت، ارز، تم',
                  color: Colors.grey,
                  onTap: () => _navigateToSettings(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: '💾 داده‌ها',
              isDark: isDark,
              children: [
                _menuItem(
                  icon: Icons.download,
                  title: 'خروجی اکسل',
                  subtitle: 'دانلود گزارش مالی',
                  color: Colors.green,
                  onTap: () => _showExportDialog(context),
                ),
                _menuItem(
                  icon: Icons.backup,
                  title: 'پشتیبان‌گیری',
                  subtitle: 'ذخیره و بازیابی داده‌ها',
                  color: Colors.orange,
                  onTap: () => _showBackupDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: '📌 درباره',
              isDark: isDark,
              children: [
                _menuItem(
                  icon: Icons.info_outline,
                  title: 'درباره ei',
                  subtitle: 'نسخه ۱.۰.۰',
                  color: const Color(0xFF6C5CE7),
                  onTap: () => _navigateToAbout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== ویجت‌های کمکی =====

  Widget _quickStat(String icon, String label, int count) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 2),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF6C5CE7),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: color, size: 20),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ===== توابع ناوبری =====

  void _navigateToType(BuildContext context, String title, String type, bool isNegative) {
    final data = context.read<DataProvider>();
    final items = data.getTransactionsByType(type);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListScreen(
          sectionTitle: title,
          items: items,
          isNegative: isNegative,
        ),
      ),
    );
  }

  void _navigateToAccounts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountsScreen(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToNotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotesScreen(),
      ),
    );
  }

  void _navigateToGoals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GoalsScreen(),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(), // ✅ const برداشته شد
      ),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  // ===== دیالوگ‌ها =====

  void _showExportDialog(BuildContext context) {
    final currency = context.read<CurrencyProvider>();
    final data = context.read<DataProvider>();

    String report = '📊 گزارش مالی ei\n';
    report += 'تاریخ: ${DateTime.now().toLocal()}\n';
    report += '=' * 40 + '\n\n';

    final types = ['income', 'expense', 'saving', 'loan', 'debt', 'credit'];
    final labels = ['درآمد', 'مخارج', 'پس‌انداز', 'وام', 'قرض', 'طلبکاری'];

    for (int i = 0; i < types.length; i++) {
      final items = data.getTransactionsByType(types[i]);
      final total = items.fold(0.0, (s, t) => s + t.amount);
      report += '${labels[i]}:\n';
      report += '  تعداد: ${items.length}\n';
      report += '  مجموع: ${currency.formatCurrency(total)}\n';
      if (items.isNotEmpty) {
        report += '  موارد:\n';
        for (var t in items) {
          report += '    - ${t.title}: ${currency.formatCurrency(t.amount)} (${t.date})\n';
        }
      }
      report += '\n';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📥 خروجی گزارش'),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                report,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💾 پشتیبان‌گیری'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('آیا می‌خواهید از داده‌ها پشتیبان بگیرید؟'),
            SizedBox(height: 8),
            Text(
              'یک فایل JSON شامل تمام اطلاعات شما ایجاد می‌شود.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final data = context.read<DataProvider>();
              data.toJson();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ پشتیبان گرفته شد')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('💾 دریافت'),
          ),
        ],
      ),
    );
  }
}