import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/providers/admin_report_provider.dart';
import 'package:ukk_percobaan2/providers/booking_provider.dart';
import 'package:ukk_percobaan2/providers/history_provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
                ChangeNotifierProvider(create: (_) => BookingProvider()),
ChangeNotifierProvider(create: (_) => HistoryProvider()), 
  ChangeNotifierProvider(create: (_) => AdminReportProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',

      // KONFIGURASI TEMA: HANYA LIGHT MODE
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B), 
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      themeMode: ThemeMode.light,

      home: const LoginView(),
    );
  }
}
