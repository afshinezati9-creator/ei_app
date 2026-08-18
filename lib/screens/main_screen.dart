// ============================================================
// مسیر: lib/screens/main_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'home_screen.dart';
import 'list_screen.dart';
import 'stats_screen.dart';
import 'more_screen.dart';
import 'add_transaction_screen.dart';
import '../widgets/lock_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart'; // ✅ اضافه شد
import '../widgets/notification_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isUnlocked = false;
  bool _notificationsShown = false;
  final AuthService _authService = AuthService();

  static const _homeKey = ValueKey('home');
  static const _listKey = ValueKey('list');
  static const _statsKey = ValueKey('stats');
  static const _moreKey = ValueKey('more');

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  Future<void> _checkLockStatus() async {
    final hasPass = await _authService.hasPassword();
    setState(() {
      _isUnlocked = !hasPass;
      _isLoading = false;
    });
  }

  void _onUnlocked() {
    setState(() {
      _isUnlocked = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNotifications();
    });
  }

  Future<void> _checkAndShowNotifications() async {
    if (_notificationsShown) return;

    final provider = context.read<NotificationProvider>();
    final service = NotificationService(); // ✅ الان کار می‌کند

    await provider.sendDueNotifications();

    final activeNotifications = provider.getActiveNotifications();

    if (activeNotifications.isNotEmpty && mounted) {
      setState(() {
        _notificationsShown = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => NotificationDialog(
          notifications: activeNotifications,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    final screens = [
      const HomeScreen(key: _homeKey),
      ListScreen(
        key: _listKey,
        sectionTitle: 'مخارج',
        items: data.getTransactionsByType('expense'),
        isNegative: true,
      ),
      const StatsScreen(key: _statsKey),
      const MoreScreen(key: _moreKey),
    ];

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isUnlocked) {
      return LockScreen(
        child: const SizedBox.shrink(),
        onUnlocked: _onUnlocked,
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'مخارج',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'آمار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'بیشتر',
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF6C5CE7),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}