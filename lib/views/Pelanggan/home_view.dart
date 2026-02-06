import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk_percobaan2/views/Pelanggan/booking.view.dart';
import '../../providers/admin_provider.dart'; // Mengambil data jadwal dari sini
import '../../providers/auth_provider.dart';
import 'history_view.dart'; // Import halaman history baru
import 'profile_view.dart'; // Import halaman profil jika ada

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Ambil data jadwal saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getJadwal();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan AdminProvider karena data jadwal ada di sana
    final adminProvider = Provider.of<AdminProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Halo, Selamat Datang", style: TextStyle(fontSize: 14)),
            Text(user?.namaLengkap ?? "Pelanggan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Tombol Ke Riwayat Tiket
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: "Riwayat Tiket",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryView()));
            },
          ),
          // Tombol Ke Profil
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileView()));
            },
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.listJadwal.isEmpty
              ? const Center(child: Text("Belum ada jadwal tersedia"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminProvider.listJadwal.length,
                  itemBuilder: (context, index) {
                    final schedule = adminProvider.listJadwal[index];
                    
                    // Asumsi API mengirim format tanggal: 2026-01-30 08:00:00
                    final tgl = schedule['tanggal_berangkat'].toString().split(' ');
                    final tanggalOnly = tgl.length > 0 ? tgl[0] : schedule['tanggal_berangkat'];
                    final jamOnly = tgl.length > 1 ? tgl[1].substring(0, 5) : ""; 

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Nama Kereta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.train, color: Color(0xFFC2185B)),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Kereta ID: ${schedule['id_kereta']}", // Bisa diganti nama_kereta jika API Join table
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                Text("Rp ${schedule['harga']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC2185B), fontSize: 16)),
                              ],
                            ),
                            const Divider(height: 24),
                            
                            // Rute & Jam
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(schedule['asal_keberangkatan'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(jamOnly, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward, color: Colors.grey),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(schedule['tujuan_keberangkatan'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(tanggalOnly, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // // Tombol Pesan (FIXED)
                            // SizedBox(
                            //   width: double.infinity,
                            //   child: ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: const Color(0xFFC2185B),
                            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            //     ),
                            //     onPressed: () {
                            //       // SOLUSI ERROR MERAH: Kirim data 'schedule' ke BookingView
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => BookingView(schedule: schedule),
                            //         ),
                            //       );
                            //     },
                            //     child: const Text("Pesan Tiket", style: TextStyle(color: Colors.white)),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}