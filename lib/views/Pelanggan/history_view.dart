import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import 'payment_screen.dart';
import 'ticket_detail_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  void _fetchHistory() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final int? idPelanggan = auth.currentUser?.idPelanggan;

    if (idPelanggan != null) {
      Provider.of<HistoryProvider>(context, listen: false).getHistory(idPelanggan);
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr == '' || dateStr == '0000-00-00 00:00:00') return '-';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('EEE, d MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final pinkColor = const Color(0xFFC2185B);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Tiket Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: pinkColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // --- UPDATE: TOMBOL KEMBALI (BACK BUTTON) ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke HomeView
          },
        ),
      ),
      body: historyProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: pinkColor))
          : historyProvider.riwayat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text("Belum ada riwayat pemesanan", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyProvider.riwayat.length,
                  itemBuilder: (context, index) {
                    final ticket = historyProvider.riwayat[index];

                    // 1. DATA PARSING (Mengambil data dari dalam list detail_penumpang)
                    List<dynamic> passengers = ticket['detail_penumpang'] ?? [];
                    var firstPax = passengers.isNotEmpty ? passengers[0] : {};

                    String pName = firstPax['nama_penumpang']?.toString() ?? '-';
                    String pSeat = firstPax['no_kursi']?.toString() ?? '-';
                    String pGerbong = firstPax['nama_gerbong']?.toString() ?? '-';

                    String status = ticket['status_pembayaran']?.toString().toLowerCase() ?? 'pending';
                    bool isLunas = status == 'lunas' || status == 'confirmed' || status == 'success';

                    int idPembelian = int.tryParse(ticket['id_pembelian'].toString()) ?? 0;
                    int totalHarga = int.tryParse(ticket['total_harga'].toString()) ?? 0;

                    return InkWell(
                      onTap: () {
                        if (isLunas) {
                          // Jika Lunas -> Buka Detail Tiket (PDF)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketDetailView(ticketData: ticket),
                            ),
                          );
                        } else {
                          // Jika Belum Bayar -> Buka Halaman Pembayaran
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                idPembelian: idPembelian,
                                totalHarga: totalHarga,
                              ),
                            ),
                          ).then((_) {
                            _fetchHistory();
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: pinkColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.airplane_ticket, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Kode: ${ticket['id_pembelian'] ?? '-'}",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isLunas ? "LUNAS" : "BELUM BAYAR",
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 10, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Nama Penumpang", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            const SizedBox(height: 4),
                                            Text(
                                              pName, 
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text("Kursi", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Gerbong $pGerbong",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            "No. $pSeat",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: pinkColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatDate(ticket['tanggal_berangkat']),
                                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${ticket['asal_keberangkatan'] ?? 'Asal'}  \u2794  ${ticket['tujuan_keberangkatan'] ?? 'Tujuan'}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}