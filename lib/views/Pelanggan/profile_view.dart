import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import '../../providers/auth_provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC2185B), width: 3)),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFC2185B),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // NAME DISPLAY
              Text(
                (user?.namaLengkap != null && user!.namaLengkap!.isNotEmpty) 
                    ? user.namaLengkap! 
                    : "Pengguna",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(user?.username ?? "-", style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 40),

              if (user != null) ...[
                _buildInfoTile("NIK", user.nik ?? "-"),
                _buildInfoTile("No. Telepon", user.telp ?? "-"),
                const SizedBox(height: 20),
              ],

              ListTile(
                tileColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Keluar Akun", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginView()), (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ]),
    );
  }
}