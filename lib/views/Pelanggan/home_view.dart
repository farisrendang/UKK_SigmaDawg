import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ukk_percobaan2/views/Pelanggan/booking.view.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'history_view.dart';
import 'profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // --- STATE VARIABLES ---
  String _stasiunAsal = "Gambir";
  String _stasiunTujuan = "Yogyakarta";
  DateTime _tanggalBerangkat = DateTime.now();

  // Variable to store search results
  List<Map<String, dynamic>> _filteredSchedules = [];
  bool _hasSearched = false; // To track if user has pressed search

  final List<String> _stations = [
    "Gambir",
    "Bandung",
    "Surabaya Gubeng",
    "Malang",
    "Yogyakarta",
    "Solo Balapan",
    "Semarang Tawang",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch all data initially
      Provider.of<AdminProvider>(context, listen: false).getJadwal();
    });
  }

  // --- LOGIC FUNCTIONS ---

  void _swapStations() {
    setState(() {
      String temp = _stasiunAsal;
      _stasiunAsal = _stasiunTujuan;
      _stasiunTujuan = temp;
      _hasSearched = false; // Reset search state on change
    });
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime maxDate = now.add(const Duration(days: 6));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBerangkat,
      firstDate: now,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFC2185B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalBerangkat = picked;
        _hasSearched = false; // Reset search state on change
      });
    }
  }

  void _showStationPicker(bool isAsal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pilih Stasiun ${isAsal ? 'Asal' : 'Tujuan'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _stations.length,
                    itemBuilder:
                        (ctx, i) => ListTile(
                          leading: const Icon(
                            Icons.train,
                            color: Color(0xFFC2185B),
                          ),
                          title: Text(_stations[i]),
                          onTap: () {
                            setState(() {
                              String selected = _stations[i];
                              if (isAsal) {
                                if (selected == _stasiunTujuan) {
                                  _stasiunTujuan = _stasiunAsal;
                                  _stasiunAsal = selected;
                                } else {
                                  _stasiunAsal = selected;
                                }
                              } else {
                                if (selected == _stasiunAsal) {
                                  _stasiunAsal = _stasiunTujuan;
                                  _stasiunTujuan = selected;
                                } else {
                                  _stasiunTujuan = selected;
                                }
                              }
                              _hasSearched = false; // Reset search state
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String formatRupiah(dynamic harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(int.parse(harga.toString()));
  }

  // --- FILTER LOGIC ---
  // --- FILTER LOGIC (UPDATED) ---
  void _performSearch(List<dynamic> allSchedules) {
    setState(() {
      _hasSearched = true;

      // 1. Format the Date to YYYY-MM-DD
      String selectedDateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(_tanggalBerangkat);

      print("--- STARTING SEARCH ---");
      print("User wants: $_stasiunAsal -> $_stasiunTujuan on $selectedDateStr");

      _filteredSchedules =
          allSchedules
              .where((schedule) {
                // 2. Get Data from Database safely
                String dbAsal =
                    (schedule['asal_keberangkatan'] ?? '').toString();
                String dbTujuan =
                    (schedule['tujuan_keberangkatan'] ?? '').toString();
                String dbDateFull = schedule['tanggal_berangkat'].toString();
                // Take only the first part of date (2026-02-09)
                String dbDate = dbDateFull.split(' ')[0];

                // 3. Robust Comparison (Ignore Case & Spaces)
                bool matchAsal =
                    dbAsal.toLowerCase().trim() ==
                    _stasiunAsal.toLowerCase().trim();
                bool matchTujuan =
                    dbTujuan.toLowerCase().trim() ==
                    _stasiunTujuan.toLowerCase().trim();
                bool matchTanggal = dbDate == selectedDateStr;

                // Debugging: Print why a schedule was rejected (Optional)
                // if (matchAsal && matchTujuan && !matchTanggal) {
                //   print("Found Route but Wrong Date: DB has $dbDate");
                // }

                return matchAsal && matchTujuan && matchTanggal;
              })
              .cast<Map<String, dynamic>>()
              .toList();

      print("Found ${_filteredSchedules.length} matching schedules.");
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    const Color primaryColor = Color(0xFFC2185B);

    // Determine which list to display
    // If searched, use filtered list. If not, use full list from provider.
    final displayList =
        _hasSearched ? _filteredSchedules : adminProvider.listJadwal;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // 1. HEADER GRADIENT
                Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat Datang,",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                user?.namaLengkap ?? "Pelanggan",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildCircularIcon(
                                icon: Icons.history_edu,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HistoryView(),
                                      ),
                                    ),
                                primaryColor: primaryColor,
                              ),
                              _buildCircularIcon(
                                icon: Icons.person,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfileView(),
                                      ),
                                    ),
                                primaryColor: primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. FLOATING SEARCH CARD
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ROW STASIUN ---
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _showStationPicker(true),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Keberangkatan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _stasiunAsal,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Stasiun $_stasiunAsal",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _swapStations,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.pink[50],
                                ),
                                child: Icon(
                                  Icons.swap_horiz,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showStationPicker(false),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Tujuan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _stasiunTujuan,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Stasiun $_stasiunTujuan",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                        const SizedBox(height: 15),

                        // --- ROW TANGGAL ---
                        InkWell(
                          onTap: _pickDate,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Tanggal Pergi",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'EEE, d MMM yyyy',
                                      ).format(_tanggalBerangkat),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- TOMBOL CARI (WITH FILTER LOGIC) ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (_stasiunAsal == _stasiunTujuan) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Asal dan Tujuan tidak boleh sama!",
                                    ),
                                  ),
                                );
                                return;
                              }
                              // TRIGGER THE FILTER
                              _performSearch(adminProvider.listJadwal);
                            },
                            child: const Text(
                              "CARI JADWAL",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. HASIL PENCARIAN (LIST JADWAL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Change text based on state
                        _hasSearched ? "Hasil Pencarian" : "Semua Jadwal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (_hasSearched)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _hasSearched = false; // Reset to show all
                            });
                          },
                          child: const Text(
                            "Reset",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  adminProvider.isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : displayList.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _hasSearched
                                    ? "Tidak ada jadwal untuk rute & tanggal ini"
                                    : "Belum ada jadwal tersedia",
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final schedule = displayList[index];
                          final tgl = schedule['tanggal_berangkat']
                              .toString()
                              .split(' ');
                          final jamOnly =
                              tgl.length > 1 ? tgl[1].substring(0, 5) : "";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.train,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Kereta ${schedule['id_kereta']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatRupiah(schedule['harga']),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedule['asal_keberangkatan'] ??
                                                'Asal',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            jamOnly,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            schedule['tujuan_keberangkatan'] ??
                                                'Tujuan',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(
                                                schedule['tanggal_berangkat'],
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => BookingView(
                                                  schedule: schedule,
                                                ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryColor,
                                        side: BorderSide(color: primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Pilih Tiket"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
