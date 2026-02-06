import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class FinanceReportView extends StatelessWidget {
  const FinanceReportView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita bisa ambil data jadwal untuk sekadar statistik sederhana
    final provider = Provider.of<AdminProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Keuangan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Statistik Dummy / Sederhana
            _buildSummaryCard("Total Tiket Terjual", "150", Colors.blue),
            _buildSummaryCard("Total Pemasukan", "Rp 7.500.000", Colors.green),
            _buildSummaryCard("Jadwal Aktif", "${provider.listJadwal.length}", Colors.orange),
            
            const SizedBox(height: 30),
            const Text("Detail transaksi dapat dilihat di database.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}