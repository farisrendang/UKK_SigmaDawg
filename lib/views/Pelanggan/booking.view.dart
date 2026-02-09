import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'history_view.dart';

class BookingView extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const BookingView({super.key, required this.schedule});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  List<Map<String, dynamic>> _passengerForms = [];

  @override
  void initState() {
    super.initState();
    _addPassenger();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null && _passengerForms.isNotEmpty) {
        setState(() {
          _passengerForms[0]['nameController'].text = user.namaLengkap ?? "";
          _passengerForms[0]['nikController'].text = user.nik ?? "";
        });
      }
    });
  }

  void _addPassenger() {
    setState(() {
      _passengerForms.add({
        'nameController': TextEditingController(),
        'nikController': TextEditingController(),
        'selectedSeat': null,
      });
    });
  }

  void _removePassenger(int index) {
    if (_passengerForms.length > 1) {
      setState(() {
        _passengerForms[index]['nameController'].dispose();
        _passengerForms[index]['nikController'].dispose();
        _passengerForms.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimal harus ada 1 penumpang!")),
      );
    }
  }

  String formatRupiah(dynamic harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(int.parse(harga.toString()));
  }

  void _openSeatSelection(int index) async {
    String idKereta = widget.schedule['id_kereta']?.toString() ?? widget.schedule['id'].toString();
    String idJadwal = widget.schedule['id']?.toString() ?? widget.schedule['id_jadwal'].toString();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _SeatSelectionSheet(
          idKereta: idKereta,
          idJadwal: idJadwal,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      bool isTaken = _passengerForms.any((p) => 
          p['selectedSeat'] != null && 
          p['selectedSeat']['id_kursi'] == result['id_kursi'] &&
          _passengerForms.indexOf(p) != index
      );

      if (isTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kursi ini sudah dipilih penumpang lain!"), backgroundColor: Colors.orange)
        );
      } else {
        setState(() {
          _passengerForms[index]['selectedSeat'] = result;
        });
      }
    }
  }

  void _processBooking() async {
    for (int i = 0; i < _passengerForms.length; i++) {
      var p = _passengerForms[i];
      if (p['nameController'].text.isEmpty || p['nikController'].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Penumpang ${i + 1} belum lengkap!"), backgroundColor: Colors.red));
        return;
      }
      if (p['selectedSeat'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Penumpang ${i + 1} belum memilih kursi!"), backgroundColor: Colors.red));
        return;
      }
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final booking = Provider.of<BookingProvider>(context, listen: false);
    
    final user = auth.currentUser;
    if (user == null || user.idPelanggan == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi habis. Silakan login ulang."), backgroundColor: Colors.red));
       return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFC2185B))),
    );

    List<Map<String, dynamic>> passengersData = [];
    
    for (var form in _passengerForms) {
      passengersData.add({
        'nik': form['nikController'].text,
        'nama': form['nameController'].text,
        'id_kursi': form['selectedSeat']['id_kursi'],
        'id_gerbong': form['selectedSeat']['id_gerbong'],
      });
    }

    String idJadwal = widget.schedule['id']?.toString() ?? widget.schedule['id_jadwal'].toString();

    final response = await booking.orderTiket(
      idPelanggan: user.idPelanggan!,
      idJadwal: idJadwal, 
      penumpang: passengersData,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (response['status'] == 'success') {
      _showSuccessDialog();
    } else {
      String msg = response['message'] ?? "Gagal memesan tiket.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 20),
          const Text("Pemesanan Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Silakan lakukan pembayaran.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {Navigator.pop(context); Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryView()));}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2185B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Lihat Tiket Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
        ]),
      ),
    );
  }

  @override
  void dispose() {
    for (var form in _passengerForms) {
      form['nameController'].dispose();
      form['nikController'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFC2185B);
    final schedule = widget.schedule;
    final user = Provider.of<AuthProvider>(context).currentUser;

    String tgl = schedule['tanggal_berangkat']?.toString() ?? DateTime.now().toString();
    String jam = tgl.split(' ').length > 1 ? tgl.split(' ')[1].substring(0, 5) : "00:00";

    int hargaPerTiket = int.tryParse(schedule['harga'].toString()) ?? 0;
    int totalBayar = hargaPerTiket * _passengerForms.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Detail Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              "Halo, ${user?.namaLengkap ?? 'Pelanggan'}", 
              style: const TextStyle(fontSize: 12, color: Colors.white70)
            ),
          ],
        ),
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white, 
        elevation: 0, 
        centerTitle: true
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO RUTE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(schedule['asal_keberangkatan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text("Keberangkatan", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                    Icon(Icons.arrow_forward, color: primaryColor),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(schedule['tujuan_keberangkatan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text("Tujuan", style: TextStyle(color: Colors.grey, fontSize: 10))]),
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
        
            // LIST FORM PENUMPANG
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Data Penumpang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addPassenger,
                  icon: const Icon(Icons.add_circle, size: 18),
                  label: const Text("Tambah"),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                )
              ],
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _passengerForms.length,
              itemBuilder: (context, index) {
                var form = _passengerForms[index];
                var seat = form['selectedSeat'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Penumpang ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                          if (_passengerForms.length > 1)
                            InkWell(
                              onTap: () => _removePassenger(index),
                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Input Nama & NIK
                      TextField(
                        controller: form['nameController'], 
                        decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12))
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: form['nikController'], 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: "NIK", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12))
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () => _openSeatSelection(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: seat != null ? primaryColor.withOpacity(0.1) : Colors.grey[100], 
                            borderRadius: BorderRadius.circular(12), 
                            border: Border.all(color: seat != null ? primaryColor : Colors.grey.shade300)
                          ),
                          child: Row(children: [
                            Icon(Icons.event_seat, color: seat != null ? primaryColor : Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(child: Text(
                              seat != null ? "Gerbong ${seat['nama_gerbong']} / No. ${seat['seat_label']}" : "Pilih Kursi",
                              style: TextStyle(
                                color: seat != null ? primaryColor : Colors.black54, 
                                fontWeight: seat != null ? FontWeight.bold : FontWeight.normal
                              ),
                            )),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          //Tombol nambah penumpang
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addPassenger,
                icon: const Icon(Icons.person_add),
                label: const Text("Tambah Penumpang Lain"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("${_passengerForms.length} Penumpang", style: const TextStyle(color: Colors.grey, fontSize: 12)), 
            Text(formatRupiah(totalBayar), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20))
          ]),
          ElevatedButton(onPressed: _processBooking, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }
}


// INTERNAL CLASS: SEAT SELECTION SHEET

class _SeatSelectionSheet extends StatefulWidget {
  final String idKereta;
  final String idJadwal;
  
  const _SeatSelectionSheet({required this.idKereta, required this.idJadwal});

  @override
  State<_SeatSelectionSheet> createState() => _SeatSelectionSheetState();
}

class _SeatSelectionSheetState extends State<_SeatSelectionSheet> {
  bool _isLoading = true;
  List<dynamic> _gerbongList = [];
  List<dynamic> _kursiList = [];
  String? _selectedGerbongId;
  String _selectedGerbongName = "";
  final Color primaryColor = const Color(0xFFC2185B);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final gerbongs = await provider.getGerbong(widget.idKereta);

    if (mounted) {
      setState(() {
        _gerbongList = gerbongs;
        if (_gerbongList.isNotEmpty) {
          _selectedGerbongId = _gerbongList[0]['id_gerbong']?.toString() ?? _gerbongList[0]['id']?.toString();
          _selectedGerbongName = _gerbongList[0]['nama_gerbong'] ?? "Gerbong 1";
          _loadKursi();
        } else {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _loadKursi() async {
    if (_selectedGerbongId == null) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final seats = await provider.getKursi(_selectedGerbongId!, widget.idJadwal);

    if (mounted) {
      setState(() {
        _kursiList = seats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int quota = 60; 
    if (_gerbongList.isNotEmpty) {
       var currentG = _gerbongList.firstWhere((g) => (g['id_gerbong']?.toString() ?? g['id'].toString()) == _selectedGerbongId, orElse: () => _gerbongList[0]);
       quota = int.tryParse(currentG['kuota']?.toString() ?? '60') ?? 60;
    }
    int totalRows = (quota / 4).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Kursi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black))],
      ),
      body: Column(
        children: [
          // TABS GERBONG
          if (_gerbongList.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _gerbongList.length,
                itemBuilder: (context, index) {
                  final g = _gerbongList[index];
                  String gId = g['id_gerbong']?.toString() ?? g['id']?.toString() ?? '';
                  String gName = g['nama_gerbong'] ?? "G-${index+1}";
                  bool isSelected = _selectedGerbongId == gId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGerbongId = gId;
                        _selectedGerbongName = gName;
                      });
                      _loadKursi();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(gName, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legendItem(Colors.grey[300]!, "Terisi"),
            const SizedBox(width: 20),
            _legendItem(Colors.white, "Tersedia", border: true),
          ]),
          const Divider(),

          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: totalRows,
                  itemBuilder: (context, rowIndex) {
                    int rowNum = rowIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSeatItem(rowNum, 1, 'A'),
                          const SizedBox(width: 8),
                          _buildSeatItem(rowNum, 2, 'B'),
                          SizedBox(width: 40, child: Center(child: Text("$rowNum", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),
                          _buildSeatItem(rowNum, 3, 'C'),
                          const SizedBox(width: 8),
                          _buildSeatItem(rowNum, 4, 'D'),
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

  Widget _buildSeatItem(int row, int colIndex, String labelChar) {
    int numericSeatNo = ((row - 1) * 4) + colIndex;
    String targetNoKursi = numericSeatNo.toString();
    String displayLabel = "$row$labelChar";

    bool isOccupied = true; 
    String? uniqueId;

    if (_kursiList.isNotEmpty) {
      try {
        var seatData = _kursiList.firstWhere(
          (k) => k['no_kursi']?.toString() == targetNoKursi,
          orElse: () => null
        );

        if (seatData != null) {
          uniqueId = seatData['id']?.toString() ?? seatData['id_kursi']?.toString();
          String status = seatData['status']?.toString() ?? '0';
          isOccupied = (status == '1' || status == 'terisi');
        } else {
          isOccupied = true; 
        }
      } catch (e) {
        isOccupied = true;
      }
    } else {
       isOccupied = true;
    }

    return InkWell(
      onTap: isOccupied ? null : () {
        Navigator.pop(context, {
          'id_kursi': uniqueId,
          'seat_label': displayLabel,
          'id_gerbong': _selectedGerbongId,
          'nama_gerbong': _selectedGerbongName
        });
      },
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: isOccupied ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isOccupied ? Colors.transparent : primaryColor),
        ),
        child: Center(
          child: Text(displayLabel, style: TextStyle(color: isOccupied ? Colors.grey : primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text, {bool border = false}) {
    return Row(children: [
      Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: border ? Border.all(color: Colors.grey) : null)),
      const SizedBox(width: 8),
      Text(text)
    ]);
  }
}