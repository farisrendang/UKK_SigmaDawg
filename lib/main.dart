import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/theme_provider.dart'; // Import Provider Tema Baru

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        
        // DAFTARKAN THEME PROVIDER DI SINI
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil status tema dari Provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      
      // TEMA TERANG
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B),
          brightness: Brightness.light
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      // TEMA GELAP
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B),
          brightness: Brightness.dark
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      // LOGIKA SWITCH TEMA
      // Jika isDarkMode true -> Pakai ThemeMode.dark
      // Jika isDarkMode false -> Pakai ThemeMode.light
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const LoginView(),
    );
  }
}