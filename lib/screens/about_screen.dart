// ============================================================
// مسیر: lib/screens/about_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره برنامه'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),

            const Text(
              'درباره برنامه',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'حسابدار شخصی هوشمند و مدرن',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ پاس دادن context
            _buildDeveloperCard(context, isDark),
            const SizedBox(height: 16),

            _buildPrivacyCard(context, isDark),
            const SizedBox(height: 18),

            _buildFeaturesTitle(),
            const SizedBox(height: 12),
            _buildFeaturesGrid(),

            const SizedBox(height: 24),

            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: RichText(
            text: TextSpan(
              text: 'e',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6C5CE7),
                letterSpacing: -1,
              ),
              children: const [
                TextSpan(
                  text: 'i',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFA29BFE),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'پایدار',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C5CE7),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ اضافه کردن پارامتر BuildContext
  Widget _buildDeveloperCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF2A2A4E)]
              : [const Color(0xFFF8F7FF), const Color(0xFFF0EDFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '👨‍💻',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'افشین عزتی',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'توسعه‌دهنده و طراح',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6C5CE7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // ✅ استفاده از context که به متد پاس داده شده
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📧 afshinezati9@gmail.com'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: const Color(0xFF6C5CE7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'afshinezati9@gmail.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6C5CE7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ اضافه کردن پارامتر BuildContext
  Widget _buildPrivacyCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF1A2A4E)]
              : [const Color(0xFFF8F9FF), const Color(0xFFF0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.20),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🛡️',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'حریم خصوصی در اولویت',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '۱۰۰٪ آفلاین',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C5CE7),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'داده‌های شما هرگز از دستگاه شما خارج نمی‌شوند. '
                  'این برنامه کاملاً بدون اتصال به اینترنت کار می‌کند و '
                  'هیچ اطلاعاتی را ذخیره، ارسال یا پردازش نمی‌کند.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF3A3A5A),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF6C5CE7).withOpacity(0.08),
                      ),
                    ),
                  ),
                  child: Text(
                    '⚖️ شما تنها مسئول نگهداری از اطلاعات خود هستید. '
                    'پس با خیال راحت از حریم شخصی خود محافظت کنید.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.grey.shade500 : const Color(0xFF6A6A8A),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTitle() {
    return Row(
      children: [
        const Text(
          '⚡',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          'امکانات برنامه',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {'icon': '💰', 'title': 'مدیریت مالی', 'sub': 'تراکنش‌ها و بودجه', 'color': 'purple'},
      {'icon': '📊', 'title': 'آمار و نمودار', 'sub': 'تحلیل هزینه‌ها', 'color': 'green'},
      {'icon': '🎯', 'title': 'اهداف مالی', 'sub': 'پیشرفت و برنامه', 'color': 'orange'},
      {'icon': '🏦', 'title': 'حساب‌های بانکی', 'sub': 'مدیریت چندحسابه', 'color': 'blue'},
      {'icon': '🔐', 'title': 'امنیت کامل', 'sub': 'رمز و اثر انگشت', 'color': 'pink'},
      {'icon': '📝', 'title': 'یادداشت‌ها', 'sub': 'برنامه‌ریزی روزانه', 'color': 'teal'},
      {'icon': '🔔', 'title': 'اعلان‌های هوشمند', 'sub': 'یادآوری و هشدار', 'color': 'red'},
      {'icon': '🎨', 'title': 'تم‌های رنگی', 'sub': 'شخصی‌سازی', 'color': 'purple'},
    ];

    final colorMap = {
      'purple': const Color(0xFF6C5CE7),
      'green': const Color(0xFF00B894),
      'orange': const Color(0xFFFDCB6E),
      'blue': const Color(0xFF0984E3),
      'pink': const Color(0xFFE84393),
      'teal': const Color(0xFF00CEC9),
      'red': const Color(0xFFFF6B6B),
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.8,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        final color = colorMap[f['color']] ?? const Color(0xFF6C5CE7);
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6C5CE7).withOpacity(0.06),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    f['icon']!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      f['title']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      f['sub']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ اضافه کردن پارامتر BuildContext
  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '📴 ۱۰۰٪ آفلاین',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C5CE7),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نظر یا پیشنهادی دارید؟',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF8A8A9E),
            ),
          ),
          Text(
            'با ایمیل به من بگید تا بهترش کنم.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF8A8A9E),
            ),
          ),
        ],
      ),
    );
  }
}