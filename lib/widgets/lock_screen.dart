import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';

class LockScreen extends StatefulWidget {
  final Widget child;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.child,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isLocked = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkLockStatus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLockStatus() async {
    final hasPass = await _authService.hasPassword();
    if (!hasPass) {
      setState(() {
        _isLocked = false;
        widget.onUnlocked();
      });
    }
  }

  Future<void> _unlock() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = '⚠️ رمز عبور را وارد کنید');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final isValid = await _authService.verifyPassword(password);

    setState(() => _isLoading = false);

    if (isValid) {
      setState(() {
        _isLocked = false;
        _errorMessage = '';
      });
      _passwordController.clear();
      widget.onUnlocked();
    } else {
      setState(() => _errorMessage = '❌ رمز عبور اشتباه است');
      _passwordController.clear();
      _animationController.forward(from: 0);
    }
  }

  Future<void> _unlockWithFingerprint() async {
    setState(() => _isLoading = true);
    final authenticated = await _authService.authenticateWithBiometricsOnly();
    setState(() => _isLoading = false);

    if (authenticated) {
      setState(() {
        _isLocked = false;
        _errorMessage = '';
      });
      _passwordController.clear();
      widget.onUnlocked();
    } else {
      setState(() => _errorMessage = '❌ اثر انگشت تأیید نشد');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    if (!_isLocked) {
      return widget.child;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.getPrimaryColor(),
              theme.getPrimaryColor().withOpacity(0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== آیکون قفل =====
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== عنوان =====
                  const Text(
                    'ei',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'برای دسترسی رمز عبور را وارد کنید',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ===== ورودی رمز =====
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final offset = (_animationController.value - 0.5) * 20;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _errorMessage.isNotEmpty
                              ? Colors.red.shade300
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '●●●●●●',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          errorText: _errorMessage.isNotEmpty ? null : null,
                        ),
                        onSubmitted: (_) => _unlock(),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ===== دکمه‌ها =====
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _unlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.getPrimaryColor(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Text(
                                  'ورود',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FutureBuilder<bool>(
                        future: _authService.isFingerprintEnabled(),
                        builder: (context, snapshot) {
                          final enabled = snapshot.data ?? false;
                          if (!enabled) return const SizedBox.shrink();
                          return CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              onPressed: _isLoading ? null : _unlockWithFingerprint,
                              icon: const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ===== لینک تنظیمات (در صورت وجود رمز) =====
                  FutureBuilder<bool>(
                    future: _authService.hasPassword(),
                    builder: (context, snapshot) {
                      final hasPass = snapshot.data ?? false;
                      if (!hasPass) return const SizedBox.shrink();
                      return TextButton(
                        onPressed: () {
                          // رفتن به تنظیمات امنیتی
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تنظیمات امنیتی'),
                              content: const Text('برای تغییر رمز یا غیرفعال‌سازی اثر انگشت به تنظیمات بروید.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('متوجه شدم'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          '🔑 تنظیمات امنیتی',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}