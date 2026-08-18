import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'main_screen.dart'; // ✅ اضافه شد

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // بعد از ۲ ثانیه به صفحه اصلی برو
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()), // ✅ تغییر
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // لوگو با حلقه‌های چرخان
            _buildAnimatedLogo(),
            const SizedBox(height: 20),

            // زیرنویس
            Text(
              'حسابدار شخصی',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 6),

            // خط زیر لوگو (شیمیر)
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),

            // دایره‌های لودینگ
            _buildLoadingDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // حلقه اول
        _buildRing(1.0, 3.0),
        // حلقه دوم
        _buildRing(0.85, 4.0, reverse: true),
        // حلقه سوم
        _buildRing(0.70, 2.5),

        // خود لوگو – با TextDirection.ltr برای درست دیده شدن
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -4 * _controller.value),
                    child: child,
                  );
                },
                child: const Text(
                  'e',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6C5CE7),
                    shadows: [
                      Shadow(
                        color: Color(0x266C5CE7),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              // نقطه روی i
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = 1 + 0.6 * (0.5 + 0.5 * _controller.value);
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C5CE7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D6C5CE7),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(top: 6, right: 2, left: 2),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -4 * _controller.value),
                    child: child,
                  );
                },
                child: const Text(
                  'i',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFA29BFE),
                    shadows: [
                      Shadow(
                        color: Color(0x26A29BFE),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRing(double size, double duration, {bool reverse = false}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * 3.14159 * (reverse ? -1 : 1);
        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 140 * size,
            height: 140 * size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (size == 0.70)
                    ? const Color(0x4D6C5CE7)
                    : (reverse
                        ? const Color(0xFFA29BFE)
                        : const Color(0xFF6C5CE7)),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final colors = [
          const Color(0xFF6C5CE7),
          const Color(0xFF7C6CF7),
          const Color(0xFF9C8CF7),
          const Color(0xFFB8ACF9),
          const Color(0xFFD5CCFF),
        ];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final phase = (index / 5) * 2 * 3.14159;
            final value = (0.5 + 0.5 * (0.5 + 0.5 * _controller.value));
            final scale = 0.6 + 0.6 * value;
            final offset = -8 * value;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}