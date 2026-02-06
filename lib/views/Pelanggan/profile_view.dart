import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/providers/auth_provider.dart';
import 'package:ukk_percobaan2/providers/theme_provider.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    // Ambil data tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFC2185B),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(user?.namaLengkap ?? "Penumpang", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user?.username ?? "", style: const TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 32),

              // --- TOMBOL TOGGLE DARK MODE ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: SwitchListTile(
                  title: const Text("Mode Gelap (Dark Mode)"),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFFC2185B),
                  ),
                  value: themeProvider.isDarkMode,
                  activeColor: const Color(0xFFC2185B),
                  onChanged: (bool value) {
                    // Panggil fungsi toggle di provider
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
              // -------------------------------

              const SizedBox(height: 20),
              
              // Tombol Logout
              ListTile(
                tileColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginView()), (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}