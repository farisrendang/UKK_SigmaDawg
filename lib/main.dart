import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/home_view.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
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
        scaffoldBackgroundColor: Colors.white, // Background Putih Bersih
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B), // Warna Utama Pink/Merah
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

      // PAKSA APLIKASI SELALU LIGHT MODE (HIRAUKAN SETTING HP)
      themeMode: ThemeMode.light,

      home: const LoginView(),
    );
  }
}
