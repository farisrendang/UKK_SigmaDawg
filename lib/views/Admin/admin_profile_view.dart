import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // Pastikan ada ThemeProvider

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user
    final user = context.read<AuthProvider>().currentUser;
    // Ambil data tema (untuk toggle dark mode)
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Petugas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Sesuaikan warna icon back dengan tema
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- AVATAR ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC2185B), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFC2185B),
                  child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              
              // --- NAMA & ROLE ---
              Text(
                user?.namaLengkap ?? "Administrator", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              Text(
                "Role: ${user?.role ?? 'Petugas'}", 
                style: const TextStyle(color: Colors.grey)
              ),
              
              const SizedBox(height: 40),

              // --- TOGGLE DARK MODE ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), 
                      blurRadius: 10,
                      offset: const Offset(0, 5)
                    )
                  ],
                ),
                child: SwitchListTile(
                  title: const Text("Mode Gelap"),
                  subtitle: const Text("Ubah tampilan aplikasi"),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFFC2185B),
                  ),
                  value: themeProvider.isDarkMode,
                  activeColor: const Color(0xFFC2185B),
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),

              const SizedBox(height: 20),
              
              // --- TOMBOL LOGOUT ---
              ListTile(
                tileColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Keluar Akun", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                ),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (c) => const LoginView()), 
                    (route) => false
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}