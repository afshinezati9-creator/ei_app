import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()..init()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'ei - حسابدار شخصی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: theme.getPrimaryColor(),
        scaffoldBackgroundColor: theme.getBackgroundColor(),
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: theme.getPrimaryColor(),
          secondary: theme.getPrimaryColor().withOpacity(0.7),
          surface: theme.getSurfaceColor(),
          background: theme.getBackgroundColor(),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          color: theme.getSurfaceColor(),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.getSurfaceColor(),
          foregroundColor: theme.getTextColor(),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: theme.getTextColor()),
          bodyMedium: TextStyle(color: theme.getTextSecondaryColor()),
          titleLarge: TextStyle(color: theme.getTextColor()),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: theme.getPrimaryColor(),
        scaffoldBackgroundColor: theme.getBackgroundColor(),
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: theme.getPrimaryColor(),
          secondary: theme.getPrimaryColor().withOpacity(0.7),
          surface: theme.getSurfaceColor(),
          background: theme.getBackgroundColor(),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          color: theme.getSurfaceColor(),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.getSurfaceColor(),
          foregroundColor: theme.getTextColor(),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: theme.getTextColor()),
          bodyMedium: TextStyle(color: theme.getTextSecondaryColor()),
          titleLarge: TextStyle(color: theme.getTextColor()),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}