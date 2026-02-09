import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Admin/finance_report_view.dart';
import '../../providers/auth_provider.dart';
import 'universal_crud_view.dart'; 
import 'manage_schedule_view.dart'; 
import '';   
import 'admin_profile_view.dart';   

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final displayName = user?.namaLengkap ?? "Petugas";

    return Scaffold(
      backgroundColor: Colors.white, 
      body: Column(
        children: [
          // HEADER (APPBAR CUSTOM)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFC2185B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dashboard Admin", style: TextStyle(color: Colors.white54, fontSize: 16)),
                    // TOMBOL PROFIL
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminProfileView()));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Halo, $displayName", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Kelola data sistem tiket", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // LIST MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // DATA KERETA
                _buildPinkMenuTile(
                  context,
                  title: "Data Kereta",
                  subtitle: "Kelola master data kereta api",
                  icon: Icons.train,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const UniversalCrudView())),
                ),

                // JADWAL
                _buildPinkMenuTile(
                  context,
                  title: "Jadwal Kereta",
                  subtitle: "Atur rute dan waktu keberangkatan",
                  icon: Icons.calendar_month,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageScheduleView())),
                ),

                // LAPORAN 
                _buildPinkMenuTile(
                  context,
                  title: "Laporan Transaksi",
                  subtitle: "Lihat history & rekap pemasukan",
                  icon: Icons.bar_chart,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminReportView())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // WIDGET HELPER: MENU TILE (Hardcoded Light/Pink Mode)
  Widget _buildPinkMenuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color bgPink = const Color(0xFFFCE4EC);
    final Color textRed = const Color(0xFFC2185B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgPink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: textRed.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: textRed, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: textRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  // WIDGET HELPER: MENU TILE 
  Widget _buildPinkMenuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color bgPink = const Color(0xFFFCE4EC);
    final Color textRed = const Color(0xFFC2185B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgPink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: textRed.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: textRed, size: 28),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, 
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios, size: 16, color: textRed),
              ],
            ),
          ),
        ),
      ),
    );
  }

