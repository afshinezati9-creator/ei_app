// ============================================================
// مسیر: lib/screens/splash_screen.dart
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _typingTimer;
  int _currentSloganIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  String _displayText = '';
  bool _showCursor = true;

  final List<String> _slogans = [
    'حواست به جیبت باشه',
    'پولتو بشناس، کنترلش کن',
    'پس‌انداز کن، هدف بذار',
    'حساب و کتابت رو قشنگ نگه دار',
    'پولتو مدیریت کن، آرامش داشته باش',
    'از امروز، پولتو بهتر بشناس',
    'پس‌انداز یعنی آزادی',
    'هر ریالت رو جای درست خرج کن',
    'با برنامه‌ریزی، پولتو مدیریت کن',
    'جیبت رو خرج نکن، مدیریتش کن',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // شروع انیمیشن تایپ‌رایتر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTypingAnimation();
    });

    // هدایت به صفحه اصلی بعد از ۵ ثانیه
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final currentSlogan = _slogans[_currentSloganIndex];

      if (_isDeleting) {
        if (_charIndex > 0) {
          _charIndex--;
          _displayText = currentSlogan.substring(0, _charIndex);
        } else {
          _isDeleting = false;
          _currentSloganIndex = (_currentSloganIndex + 1) % _slogans.length;
          _charIndex = 0;
        }
      } else {
        if (_charIndex < currentSlogan.length) {
          _charIndex++;
          _displayText = currentSlogan.substring(0, _charIndex);
        } else {
          _isDeleting = true;
          timer.cancel();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _startTypingAnimation();
          });
        }
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF6C5CE7),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6C5CE7), const Color(0xFF8A7CF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== لوگو =====
              _buildAnimatedLogo(),
              const SizedBox(height: 8),

              // ===== شعار تایپ‌رایتر =====
              _buildTypingSlogan(),

              const SizedBox(height: 16),
              _buildUnderline(),
              const SizedBox(height: 24),

              // ===== نقاط لودینگ =====
              _buildLoadingDots(),

              const SizedBox(height: 40),
              // ===== نسخه =====
              Text(
                'نسخه 6.۰.5',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildRing(
          1.0,
          3.0,
          const Color(0xFF6C5CE7),
          Colors.white.withOpacity(0.5),
        ),
        _buildRing(
          0.85,
          4.0,
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
          reverse: true,
        ),
        _buildRing(
          0.70,
          2.5,
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ),

        // خود لوگو
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
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.white24, blurRadius: 30)],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = 1 + 0.6 * (0.5 + 0.5 * _controller.value);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.white38, blurRadius: 20),
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
                    color: Colors.white70,
                    shadows: [Shadow(color: Colors.white24, blurRadius: 30)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRing(
    double size,
    double duration,
    Color color1,
    Color color2, {
    bool reverse = false,
  }) {
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
                color: (size == 0.70) ? color2 : color1,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingSlogan() {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _displayText,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 2),
          AnimatedOpacity(
            opacity: _showCursor ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(width: 2, height: 22, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderline() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index / 5;
            final value = (0.5 + 0.5 * _controller.value);
            final opacity = 0.15 + 0.85 * value;
            final scale = 0.8 + 0.2 * value;
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
