import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TicketDetailView extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailView({super.key, required this.ticketData});

  Future<void> _printPdf() async {
    final doc = pw.Document();

    // Helper format rupiah untuk PDF
    String formatRupiah(dynamic value) {
      if (value == null) return "Rp 0";
      final number = int.tryParse(value.toString()) ?? 0;
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // JUDUL
                pw.Center(
                  child: pw.Text("E-TIKET KERETA API", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                
                // INFO UTAMA
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Kode Booking: ${ticketData['id_pembelian']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.Text("Status: LUNAS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                  ]
                ),
                pw.SizedBox(height: 10),
                
                // DETAIL PERJALANAN
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Kereta: ${ticketData['nama_kereta'] ?? 'Train'} (${ticketData['kelas'] ?? '-'})", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text("Berangkat: ${ticketData['tanggal_berangkat']}"),
                      pw.Text("Tiba: ${ticketData['tanggal_kedatangan']}"),
                      pw.SizedBox(height: 5),
                      pw.Text("Rute: ${ticketData['asal_keberangkatan']} -> ${ticketData['tujuan_keberangkatan']}"),
                    ]
                  )
                ),
                
                pw.SizedBox(height: 20),
                pw.Text("Detail Penumpang:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),

                // --- UPDATE: Nama, Gerbong, dan Kursi ---
                ...(ticketData['detail_penumpang'] as List).map((p) => 
                  pw.Bullet(
                    text: "${p['nama_penumpang']} - (Gerbong ${p['nama_gerbong'] ?? '-'} dan Kursi ${p['no_kursi']})"
                  )
                ).toList(),

                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Total Harga: ${formatRupiah(ticketData['total_harga'])}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tiket"), backgroundColor: const Color(0xFFC2185B)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 100),
                  const SizedBox(height: 10),
                  Text("Kode: ${ticketData['id_pembelian']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
                  const SizedBox(height: 5),
                  const Text("Tunjukkan kode ini kepada petugas saat boarding.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _printPdf,
                icon: const Icon(Icons.print),
                label: const Text("Cetak / Simpan PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}