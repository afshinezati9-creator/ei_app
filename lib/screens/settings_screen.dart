import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/data_provider.dart';
import '../providers/date_provider.dart'; // اضافه شده
import '../utils/validators.dart';
import '../widgets/lock_screen.dart';
import 'package:ei_app/providers/providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _hasPassword = false;
  bool _fingerprintEnabled = false;
  bool _fingerprintAvailable = false;
  bool _isLoading = true;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _hasPassword = await _authService.hasPassword();
    _fingerprintEnabled = await _authService.isFingerprintEnabled();
    _fingerprintAvailable = await _authService.isFingerprintAvailable();
    setState(() => _isLoading = false);
  }

  Future<void> _savePassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty && confirm.isEmpty) {
      // حذف رمز
      await _authService.removePassword();
      await _authService.setFingerprintEnabled(false);
      setState(() {
        _hasPassword = false;
        _fingerprintEnabled = false;
        _statusMessage = '✅ رمز عبور حذف شد';
      });
      await _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔓 رمز عبور حذف شد')),
      );
      return;
    }

    if (password != confirm) {
      setState(() => _statusMessage = '⚠️ رمزها با هم مطابقت ندارند');
      return;
    }

    if (!Validators.isValidPassword(password)) {
      setState(() => _statusMessage = '⚠️ رمز باید ۶ رقم باشد');
      return;
    }

    await _authService.savePassword(password);
    setState(() {
      _hasPassword = true;
      _statusMessage = '✅ رمز عبور ذخیره شد';
    });
    _passwordController.clear();
    _confirmPasswordController.clear();
    await _loadSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔑 رمز عبور ذخیره شد')),
    );
  }

  Future<void> _toggleFingerprint(bool value) async {
    if (value && !_fingerprintAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ اثر انگشت در این دستگاه پشتیبانی نمی‌شود')),
      );
      return;
    }
    if (value && !_hasPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ ابتدا رمز عبور را تنظیم کنید')),
      );
      return;
    }
    await _authService.setFingerprintEnabled(value);
    setState(() {
      _fingerprintEnabled = value;
      _statusMessage = value ? '✅ اثر انگشت فعال شد' : '❌ اثر انگشت غیرفعال شد';
    });
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ===== تنظیمات ارز =====
                  _buildSection(
                    title: '💰 ارز',
                    child: _buildCurrencySelector(currency),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // ===== انتخاب فرمت تاریخ (اضافه شده) =====
                  _buildSection(
                    title: '📅 فرمت تاریخ',
                    isDark: isDark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DateFormatType.values.map((format) {
                        return Consumer<DateProvider>(
                          builder: (context, provider, child) {
                            return ChoiceChip(
                              label: Text(provider.getFormatLabel(format)),
                              selected: provider.currentFormat == format,
                              onSelected: (selected) {
                                if (selected) {
                                  provider.setFormat(format);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✅ فرمت تاریخ به ${provider.getFormatLabel(format)} تغییر کرد'),
                                    ),
                                  );
                                }
                              },
                              selectedColor: const Color(0xFF6C5CE7),
                              labelStyle: TextStyle(
                                color: provider.currentFormat == format ? Colors.white : null,
                                fontSize: 13,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== تنظیمات امنیتی =====
                  _buildSection(
                    title: '🔐 امنیت',
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رمز عبور
                        Text(
                          _hasPassword ? 'رمز عبور تنظیم شده است' : 'رمز عبور تنظیم نشده',
                          style: TextStyle(
                            color: _hasPassword ? Colors.green : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: _hasPassword ? 'رمز جدید (۶ رقم)' : 'رمز عبور (۶ رقم)',
                                  hintText: '●●●●●●',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  counterText: '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: 'تکرار رمز',
                                  hintText: '●●●●●●',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_statusMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _statusMessage.startsWith('✅')
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _savePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C5CE7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _hasPassword ? 'تغییر رمز' : 'تنظیم رمز',
                                ),
                              ),
                            ),
                            if (_hasPassword)
                              const SizedBox(width: 8),
                            if (_hasPassword)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
                                    _savePassword(); // حذف رمز با خالی بودن هر دو
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('حذف رمز'),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // اثر انگشت
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: _fingerprintAvailable
                                      ? (_fingerprintEnabled ? Colors.green : Colors.grey)
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _fingerprintAvailable
                                      ? 'اثر انگشت'
                                      : 'اثر انگشت (پشتیبانی نمی‌شود)',
                                  style: TextStyle(
                                    color: _fingerprintAvailable
                                        ? (_fingerprintEnabled ? Colors.green : Colors.grey)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _fingerprintEnabled && _fingerprintAvailable,
                              onChanged: _fingerprintAvailable ? _toggleFingerprint : null,
                              activeColor: const Color(0xFF6C5CE7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== تنظیمات تم =====
                  _buildSection(
                    title: '🎨 تم',
                    isDark: isDark,
                    child: _buildThemeSelector(theme, isDark),
                  ),
                  const SizedBox(height: 12),

                  // ===== تنظیمات پیشرفته =====
                  _buildSection(
                    title: '⚙️ پیشرفته',
                    isDark: isDark,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('پاک کردن همه داده‌ها'),
                          subtitle: const Text('تمام تراکنش‌ها و تنظیمات حذف می‌شود'),
                          onTap: () => _showClearDataDialog(context),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('درباره'),
                          subtitle: const Text('نسخه ۱.۰.۰'),
                          onTap: () => _showAboutDialog(context),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(CurrencyProvider currency) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: currency.currencies.map((c) {
        final isSelected = c == currency.symbol;
        return FilterChip(
          label: Text(c),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) currency.setCurrency(c);
          },
          selectedColor: const Color(0xFF6C5CE7),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemeSelector(ThemeProvider theme, bool isDark) {
    final colors = ['purple', 'blue', 'pink', 'green'];
    final labels = ['بنفش', 'آبی', 'صورتی', 'سبز'];
    final colorMap = {
      'purple': const Color(0xFF6C5CE7),
      'blue': const Color(0xFF0984E3),
      'pink': const Color(0xFFE84393),
      'green': const Color(0xFF00B894),
    };

    return Column(
      children: [
        Row(
          children: [
            const Text('تم رنگی: '),
            const SizedBox(width: 8),
            ...colors.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              final isSelected = c == theme.colorTheme;
              return GestureDetector(
                onTap: () => theme.setColorTheme(c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorMap[c],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('حالت تاریک'),
            Switch(
              value: theme.themeMode == 'dark' ||
                  (theme.themeMode == 'system' && isDark),
              onChanged: (value) {
                theme.setThemeMode(value ? 'dark' : 'light');
              },
              activeColor: const Color(0xFF6C5CE7),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ هشدار!'),
        content: const Text(
          'آیا از پاک کردن همه داده‌ها مطمئن هستید؟\n\nاین عمل غیرقابل بازگشت است و تمام تراکنش‌ها، حساب‌ها، اهداف و تنظیمات شما حذف می‌شود.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final data = context.read<DataProvider>();
              data.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ همه داده‌ها پاک شد')),
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
            Text('حسابدار شخصی پیشرفته با قابلیت‌های:'),
            SizedBox(height: 4),
            Text('• مدیریت تراکنش‌ها'),
            Text('• حساب‌های بانکی'),
            Text('• اهداف مالی'),
            Text('• آمار و نمودارها'),
            Text('• رمز عبور و اثر انگشت'),
            SizedBox(height: 8),
            Text('ساخته شده با ❤️'),
          ],
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
}