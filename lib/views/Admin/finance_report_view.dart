import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_report_provider.dart';

class AdminReportView extends StatefulWidget {
  const AdminReportView({super.key});

  @override
  State<AdminReportView> createState() => _AdminReportViewState();
}

class _AdminReportViewState extends State<AdminReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminReportProvider>(context, listen: false);
      provider.getAllHistory();
      provider.getMonthlyRecap();
    });
  }

  String formatRupiah(dynamic val) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(int.tryParse(val.toString()) ?? 0);
  }

  // Function to open the Date Picker
  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFC2185B),
            colorScheme: const ColorScheme.light(primary: Color(0xFFC2185B)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminReportProvider>(context);
    final pinkColor = const Color(0xFFC2185B);

    // --- FILTER LOGIC ---
    
    // Filter Transactions
    List<dynamic> filteredTransactions = provider.allTransactions;
    if (_selectedDateRange != null) {
      filteredTransactions = provider.allTransactions.where((item) {
        if (item['tanggal_pembelian'] == null) return false;
        try {
          DateTime date = DateTime.parse(item['tanggal_pembelian']);
          return date.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
                 date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter Monthly Recap
    List<dynamic> filteredRecap = provider.monthlyRecap;
    if (_selectedDateRange != null) {
      filteredRecap = provider.monthlyRecap.where((item) {
        if (item['bulan'] == null) return false; // Format YYYY-MM
        try {
          DateTime recapDate = DateTime.parse("${item['bulan']}-01");
          
          DateTime startMonth = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, 1);
          DateTime endMonth = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month + 1, 0); // End of month
          
          return recapDate.isAtSameMomentAs(startMonth) || 
                 (recapDate.isAfter(startMonth) && recapDate.isBefore(endMonth.add(const Duration(seconds: 1))));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Laporan Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_selectedDateRange != null)
              Text(
                "${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              )
          ],
        ),
        backgroundColor: pinkColor,
        foregroundColor: Colors.white,
        actions: [
          // Clear Filter Button
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: "Hapus Filter",
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                });
              },
            ),
          // Filter Button
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Filter Tanggal",
            onPressed: _pickDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Semua Transaksi", icon: Icon(Icons.list_alt)),
            Tab(text: "Rekap Pemasukan", icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: pinkColor))
          : TabBarView(
              controller: _tabController,
              children: [
                //TRANSAKSI (FILTERED) ---
               filteredTransactions.isEmpty 
  ? const Center(child: Text("Tidak ada data pada tanggal ini"))
  : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final item = filteredTransactions[index];
        
        String displayName = 'Tanpa Nama';
        
        if (item['pemesan'] != null && item['pemesan'].toString().isNotEmpty) {
          displayName = item['pemesan'];
        } 
        else if (item['detail_penumpang'] != null && (item['detail_penumpang'] as List).isNotEmpty) {
          displayName = item['detail_penumpang'][0]['nama_penumpang'] ?? 'Tanpa Nama';
        }

        //LOGIKA STATUS
        String status = item['status_pembayaran']?.toString().toLowerCase() ?? 'pending';
        bool isLunas = status == 'lunas' || status == 'success' || status == 'confirmed';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLunas ? Colors.green[100] : Colors.orange[100],
              child: Icon(
                isLunas ? Icons.check : Icons.access_time,
                color: isLunas ? Colors.green : Colors.orange,
              ),
            ),
            
            title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['nama_kereta'] ?? 'KA'} (${item['asal_keberangkatan'] ?? '-'} -> ${item['tujuan_keberangkatan'] ?? '-'})"),
                Text(item['tanggal_pembelian'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Text(
              formatRupiah(item['total_harga']),
              style: TextStyle(fontWeight: FontWeight.bold, color: pinkColor, fontSize: 14),
            ),
          ),
        );
      },
    ),

                // REKAP BULANAN (FILTERED) 
                filteredRecap.isEmpty
                  ? const Center(child: Text("Tidak ada rekap pada periode ini"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRecap.length,
                      itemBuilder: (context, index) {
                        final item = filteredRecap[index];
                        
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Periode: ${item['bulan']}", // Format: 2026-02
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: pinkColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${item['total_transaksi']} Transaksi",
                                        style: TextStyle(color: pinkColor, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(height: 30),
                                const Text("Total Pemasukan", style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 5),
                                Text(
                                  formatRupiah(item['total_pemasukan']),
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
    );
  }
}