import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import '../../providers/auth_provider.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Petugas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // AVATAR
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC2185B), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFC2185B),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // NAMA & ROLE
              Text(
                user?.namaLengkap ?? "Administrator",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "Role: ${user?.role ?? 'Petugas'}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // TOMBOL LOGOUT (Hanya ini yang tersisa)
              ListTile(
                tileColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Keluar Akun",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => const LoginView()),
                    (route) => false,
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
