import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/supabase_config.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(
              'خطأ بالتطبيق (build):\n\n${details.exception}\n\n${details.stack}',
              style: const TextStyle(color: Colors.red, fontSize: 11),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    try {
      await SupabaseConfig.init();
    } catch (e, st) {
      runApp(_ErrorApp(message: 'فشل الاتصال بـ Supabase:\n$e\n\n$st'));
      return;
    }

    runApp(const SpeedApp());
  }, (error, stack) {
    runApp(_ErrorApp(message: 'خطأ غير متوقع:\n$error\n\n$stack'));
  });
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

class SpeedApp extends StatelessWidget {
  const SpeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPEED Car Rental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: const SplashScreen(),
    );
  }
}
