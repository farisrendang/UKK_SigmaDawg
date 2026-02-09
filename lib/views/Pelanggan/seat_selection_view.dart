import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeatSelectionView extends StatefulWidget {
  final String idKereta;
  final Function(Map<String, dynamic>) onSeatSelected; 

  const SeatSelectionView({
    super.key, 
    required this.idKereta, 
    required this.onSeatSelected
  });

  @override
  State<SeatSelectionView> createState() => _SeatSelectionViewState();
}

class _SeatSelectionViewState extends State<SeatSelectionView> {
  // Base URL API 
  final String baseUrl = "https://micke.my.id/api/ukk";

  bool _isLoading = false;
  List<dynamic> _listGerbong = [];
  List<dynamic> _listKursi = [];

  String? _selectedGerbongId;
  Map<String, dynamic>? _selectedSeat;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi lokal saat halaman dibuka
    _getGerbongByKereta(widget.idKereta);
  }

  // 1. GET GERBONG BY KERETA (LOKAL)
  Future<void> _getGerbongByKereta(String idKereta) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/gerbong.php?id_kereta=$idKereta'));
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        setState(() {
          _listGerbong = data['data'];
        });
      } else {
        setState(() => _listGerbong = []);
      }
    } catch (e) {
      print("Error Get Gerbong: $e");
      setState(() => _listGerbong = []);
    }
    setState(() => _isLoading = false);
  }

  // 2. GET KURSI BY GERBONG (LOKAL)
  Future<void> _getKursiByGerbong(String idGerbong) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/kursi.php?id_gerbong=$idGerbong'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _listKursi = data['data'];
        });
      } else {
        setState(() => _listKursi = []);
      }
    } catch (e) {
      print("Error Get Kursi: $e");
      setState(() => _listKursi = []);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // --- FILTER DUPLIKAT (PENTING AGAR TIDAK ERROR MERAH) ---
    final seenIds = <String>{};
    final uniqueGerbongList = _listGerbong.where((gerbong) {
      final id = gerbong['id_gerbong'].toString();
      if (seenIds.contains(id)) {
        return false;
      } else {
        seenIds.add(id);
        return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Kursi"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          // 1. DROPDOWN PILIH GERBONG
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Pilih Gerbong",
                prefixIcon: const Icon(Icons.train, color: Color(0xFFC2185B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _selectedGerbongId,
              // Gunakan list lokal yang sudah difilter
              items: uniqueGerbongList.map<DropdownMenuItem<String>>((gerbong) {
                return DropdownMenuItem(
                  value: gerbong['id_gerbong'].toString(),
                  child: Text(
                    "${gerbong['nama_gerbong']} (Sisa: ${gerbong['kuota']})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedGerbongId = value;
                  _selectedSeat = null; // Reset kursi
                });
                // Panggil fungsi lokal ambil kursi
                _getKursiByGerbong(value);
              },
            ),
          ),

          // 2. GRID KURSI
          Expanded(
            child: _selectedGerbongId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.touch_app, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Silakan pilih gerbong terlebih dahulu", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _listKursi.isEmpty
                        ? const Center(child: Text("Belum ada data kursi di gerbong ini"))
                        : GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, 
                              childAspectRatio: 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _listKursi.length,
                            itemBuilder: (context, index) {
                              final seat = _listKursi[index];
                              
                              // Cek Status
                              bool isBooked = seat['status'].toString().toLowerCase() == 'terisi' || 
                                              seat['status'].toString().toLowerCase() == 'booked'; 
                              bool isSelected = _selectedSeat == seat;

                              return InkWell(
                                onTap: isBooked
                                    ? null
                                    : () {
                                        setState(() => _selectedSeat = seat);
                                      },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? Colors.grey.shade300
                                        : isSelected
                                            ? const Color(0xFFC2185B)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFC2185B) : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: const Color(0xFFC2185B).withOpacity(0.3), blurRadius: 8)]
                                        : [],
                                  ),
                                  child: Center(
                                    child: isBooked 
                                      ? const Icon(Icons.close, color: Colors.grey)
                                      : Text(
                                          seat['no_kursi'] ?? "${index + 1}",
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFFC2185B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          
          // 3. TOMBOL KONFIRMASI
          if (_selectedSeat != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))]
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    widget.onSeatSelected({
                      'id_kursi': _selectedSeat!['id_kursi'].toString(),
                      'no_kursi': _selectedSeat!['no_kursi'],
                      'id_gerbong': _selectedGerbongId,
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Pilih Kursi ${_selectedSeat!['no_kursi']}", 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}