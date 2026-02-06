import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Default: Light Mode (false)
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme(); // Load tema saat aplikasi dibuka
  }

  // Fungsi untuk mengubah tema (Toggle)
  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners(); // Kabari seluruh aplikasi bahwa tema berubah

    // Simpan ke memori HP
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
  }

  // Fungsi memuat tema yang tersimpan
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}