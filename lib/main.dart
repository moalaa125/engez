import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const EngezApp());
}

class EngezApp extends StatelessWidget {
  const EngezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engez - إنجز',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Enforce RTL for Egyptian Arabic
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'), // Arabic, Egypt
      ],
      locale: const Locale('ar', 'EG'),
      home: const LoginScreen(),
    );
  }
}
