import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
// import 'history_view.dart'; // Ensure this exists or comment out if not needed

class BookingView extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const BookingView({super.key, required this.schedule});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  
  // Changed to List to support multi-seat selection in future, but logic currently handles 1
  List<Map<String, dynamic>> _selectedSeats = []; 

  String formatRupiah(dynamic harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(int.parse(harga.toString()));
  }

  void _openSeatSelection() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SeatSelectionSheet(
        idKereta: (widget.schedule['id_kereta'] ?? widget.schedule['id']).toString(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedSeats = [result]; // Currently only 1 passenger supported in this flow
      });
    }
  }

  void _processBooking() async {
    if (_namaController.text.isEmpty || _nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan NIK wajib diisi!"), backgroundColor: Colors.red));
      return;
    }
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan pilih kursi terlebih dahulu!"), backgroundColor: Colors.red));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    
    if (user == null || user.idPelanggan == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi habis. Silakan login ulang."), backgroundColor: Colors.red));
      return;
    }

    String idJadwal = (widget.schedule['id'] ?? widget.schedule['id_jadwal']).toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFC2185B))),
    );

    // Using the first selected seat for the first passenger
    var seat = _selectedSeats[0];

    List<Map<String, String>> passengers = [
      {
        'nik': _nikController.text,
        'nama': _namaController.text,
        'id_kursi': seat['id_kursi'].toString(),
        'id_gerbong': seat['id_gerbong'].toString(),
      },
    ];

    bool success = await auth.bookTicket(
      idJadwal: idJadwal, 
      passengers: passengers,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildSuccessPaymentSheet(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memesan tiket."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFC2185B);
    final schedule = widget.schedule;
    String tgl = schedule['tanggal_berangkat']?.toString() ?? DateTime.now().toString();
    String jam = tgl.split(' ').length > 1 ? tgl.split(' ')[1].substring(0, 5) : "00:00";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Detail Pemesanan"), backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Info Perjalanan"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], border: Border.all(color: primaryColor.withOpacity(0.1))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(schedule['asal_keberangkatan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), const Text("Keberangkatan", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                    Icon(Icons.arrow_forward, color: primaryColor),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(schedule['tujuan_keberangkatan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), const Text("Tujuan", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                  ]),
                  const Divider(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [Icon(Icons.calendar_today, size: 16, color: primaryColor), const SizedBox(width: 8), Text(tgl.split(' ')[0])]),
                    Row(children: [Icon(Icons.access_time, size: 16, color: primaryColor), const SizedBox(width: 8), Text(jam)]),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Data Penumpang"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(children: [
                _buildTextField(label: "Nama Lengkap (Sesuai KTP)", icon: Icons.person, controller: _namaController),
                const SizedBox(height: 16),
                _buildTextField(label: "Nomor Induk Kependudukan (NIK)", icon: Icons.badge, controller: _nikController, isNumber: true),
              ]),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Pilihan Kursi"),
            InkWell(
              onTap: _openSeatSelection,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _selectedSeats.isNotEmpty ? primaryColor.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _selectedSeats.isNotEmpty ? primaryColor : Colors.grey.shade300)),
                child: Row(children: [
                  Icon(Icons.event_seat, color: _selectedSeats.isNotEmpty ? primaryColor : Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selectedSeats.isNotEmpty ? "Kursi Terpilih" : "Pilih Kursi & Gerbong", style: TextStyle(color: _selectedSeats.isNotEmpty ? primaryColor : Colors.black87, fontWeight: _selectedSeats.isNotEmpty ? FontWeight.bold : FontWeight.normal)),
                    if (_selectedSeats.isNotEmpty) Text("Gerbong ${_selectedSeats[0]['nama_gerbong']} / No. ${_selectedSeats[0]['no_kursi']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ])),
                  Icon(Icons.arrow_forward_ios, size: 16, color: _selectedSeats.isNotEmpty ? primaryColor : Colors.grey),
                ]),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 12)), Text(formatRupiah(schedule['harga'] ?? 0), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20))]),
          ElevatedButton(onPressed: _processBooking, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  Widget _buildTextField({required String label, required IconData icon, required TextEditingController controller, bool isNumber = false}) => TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[50]));
  Widget _buildSuccessPaymentSheet() => Container(padding: const EdgeInsets.all(30), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 60)), const SizedBox(height: 20), const Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text("Tiket Anda telah terbit.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const SizedBox(height: 30), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {Navigator.pop(context); Navigator.pop(context); /*Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryView()));*/ }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2185B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Lihat Tiket Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]));
}

// =========================================================================
// INTERNAL CLASS: SEAT SELECTION SHEET (WITH CUSTOM LAYOUT)
// =========================================================================
class _SeatSelectionSheet extends StatefulWidget {
  final String idKereta;
  const _SeatSelectionSheet({required this.idKereta});

  @override
  State<_SeatSelectionSheet> createState() => _SeatSelectionSheetState();
}

class _SeatSelectionSheetState extends State<_SeatSelectionSheet> {
  String? _selectedGerbongId;
  String? _selectedGerbongName; // For passing back to parent
  final Color primaryColor = const Color(0xFFC2185B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.getGerbongByKereta(widget.idKereta).then((_) {
        if (provider.listGerbong.isNotEmpty) {
          final g = provider.listGerbong[0];
          final firstId = g['id']?.toString() ?? g['id_gerbong']?.toString();
          final firstName = g['nama_gerbong'] ?? "Gerbong";
          if (firstId != null) {
            setState(() {
              _selectedGerbongId = firstId;
              _selectedGerbongName = firstName;
            });
            provider.getKursiByGerbong(firstId);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    // Calculate rows for the custom layout (2-2 configuration)
    // Assuming data is linear list, we divide by 4 to get rows
    int totalRows = (provider.listKursi.length / 4).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Kursi"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
      ),
      body: Column(
        children: [
          // DROPDOWN
          Container(
            padding: const EdgeInsets.all(16),
            child: provider.listGerbong.isEmpty
                ? const Text("Memuat gerbong...")
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Pilih Gerbong", border: OutlineInputBorder()),
                    value: _selectedGerbongId,
                    isExpanded: true,
                    items: provider.listGerbong.map((gerbong) {
                      final id = gerbong['id']?.toString() ?? gerbong['id_gerbong']?.toString();
                      final nama = gerbong['nama_gerbong'] ?? "Gerbong $id";
                      final sisa = gerbong['jumlah_kursi'] ?? gerbong['kapasitas'] ?? 0;
                      return DropdownMenuItem(value: id, child: Text("$nama (Kapasitas: $sisa)"));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final g = provider.listGerbong.firstWhere((element) => (element['id']?.toString() ?? element['id_gerbong'].toString()) == val);
                        setState(() {
                          _selectedGerbongId = val;
                          _selectedGerbongName = g['nama_gerbong'];
                        });
                        provider.getKursiByGerbong(val);
                      }
                    },
                  ),
          ),

          // LEGEND
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(Colors.white, Colors.grey, "Tersedia", Colors.black),
                _buildLegend(Colors.orange[800]!, Colors.transparent, "Terisi", Colors.white),
                // _buildLegend(Colors.blue, Colors.transparent, "Dipilih", Colors.white), // Not needed for single select
              ],
            ),
          ),

          // COLUMN LABELS (A B - C D)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLabel("A"), _buildLabel("B"),
              const SizedBox(width: 40), // Aisle
              _buildLabel("C"), _buildLabel("D"),
            ],
          ),
          const SizedBox(height: 10),

          // SEAT LIST (CUSTOM LAYOUT)
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.listKursi.isEmpty
                    ? const Center(child: Text("Belum ada data kursi"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: totalRows,
                        itemBuilder: (context, rowIndex) {
                          int startIdx = rowIndex * 4;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSeatItem(provider.listKursi, startIdx),     // A
                                _buildSeatItem(provider.listKursi, startIdx + 1), // B
                                
                                // ROW NUMBER (AISLE)
                                SizedBox(
                                  width: 40,
                                  child: Center(child: Text("${rowIndex + 1}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                                ),

                                _buildSeatItem(provider.listKursi, startIdx + 2), // C
                                _buildSeatItem(provider.listKursi, startIdx + 3), // D
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(List<dynamic> allSeats, int index) {
    if (index >= allSeats.length) {
      return Container(width: 45, height: 45, margin: const EdgeInsets.symmetric(horizontal: 4)); // Empty placeholder
    }

    final seat = allSeats[index];
    final status = seat['status']?.toString() ?? '1';
    final isAvailable = (seat['is_available'] == 1 || status == 'available' || status == '1');
    final seatNo = seat['nomor_kursi']?.toString() ?? seat['no_kursi'].toString();

    // Mapping index to letters just for display logic if needed, but we rely on data
    String letter = "";
    int mod = index % 4;
    if (mod == 0) letter = "A";
    else if (mod == 1) letter = "B";
    else if (mod == 2) letter = "C";
    else letter = "D";

    return InkWell(
      onTap: isAvailable
          ? () {
              Navigator.pop(context, {
                'id_kursi': seat['id'] ?? seat['id_kursi'],
                'no_kursi': seatNo,
                'id_gerbong': _selectedGerbongId,
                'nama_gerbong': _selectedGerbongName
              });
            }
          : null,
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.grey[200] : Colors.orange[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isAvailable ? Colors.grey[400]! : Colors.orange[900]!),
        ),
        child: Center(
          child: isAvailable 
            ? Text(
                letter, 
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
              )
            : const Icon(Icons.close, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  Widget _buildLegend(Color bg, Color border, String text, Color textC) {
    return Row(
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: border)),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12))
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: 45, margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
    );
  }
}