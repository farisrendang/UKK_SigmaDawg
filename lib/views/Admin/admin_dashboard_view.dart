import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/login_view.dart';
import '../../providers/auth_provider.dart';
import 'universal_crud_view.dart'; 
import 'manage_schedule_view.dart'; 
import 'finance_report_view.dart'; 
import 'manage_gerbong_view.dart';
import 'admin_profile_view.dart'; // Jangan lupa import ini

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // HEADER (Warna Gelap)
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dashboard Admin",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    // ROW TOMBOL (PROFIL & LOGOUT)
                    Row(
                      children: [
                        // 1. Tombol Profil (BARU)
                        IconButton(
                          icon: const Icon(Icons.account_circle, color: Colors.white),
                          tooltip: "Profil Petugas",
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (c) => const AdminProfileView())
                            );
                          },
                        ),
                        // 2. Tombol Logout
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white54),
                          tooltip: "Keluar",
                          onPressed: () async {
                            await Provider.of<AuthProvider>(context, listen: false).logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (c) => const LoginView()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Halo, ${user?.namaLengkap ?? 'Petugas'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Kelola sistem tiket dari sini",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // MENU GRID (TETAP SAMA)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Data Kereta",
                    icon: Icons.train,
                    iconColor: Colors.blue,
                    bgColor: Colors.blue.shade50,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const UniversalCrudView())),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Data Gerbong",
                    icon: Icons.chair,
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.shade50,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageGerbongView())),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Jadwal",
                    icon: Icons.calendar_today,
                    iconColor: Colors.green,
                    bgColor: Colors.green.shade50,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageScheduleView())),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Laporan",
                    icon: Icons.bar_chart,
                    iconColor: Colors.purple,
                    bgColor: Colors.purple.shade50,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FinanceReportView())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}