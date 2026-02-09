import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import 'crud_template_view.dart';

class ManageScheduleView extends StatefulWidget {
  const ManageScheduleView({super.key});

  @override
  State<ManageScheduleView> createState() => _ManageScheduleViewState();
}

class _ManageScheduleViewState extends State<ManageScheduleView> {
  final List<String> stations = [
    "Gambir", "Bandung", "Surabaya Gubeng", "Malang", 
    "Yogyakarta", "Solo Balapan", "Semarang Tawang", "Jakarta" 
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      admin.getJadwal();
      admin.getKereta();
    });
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;

    // --- LOGIKA DROPDOWN ---
    String? selectedKereta = item?['id_kereta']?.toString();
    
    String rawAsal = item?['asal_keberangkatan'] ?? stations[0];
    String rawTujuan = item?['tujuan_keberangkatan'] ?? stations[1];


    String asal = rawAsal;
    String tujuan = rawTujuan;
    
    DateTime date = isEdit ? DateTime.parse(item['tanggal_berangkat']) : DateTime.now();
    TimeOfDay timeBerangkat = isEdit 
        ? TimeOfDay.fromDateTime(DateTime.parse(item['tanggal_berangkat'])) 
        : TimeOfDay.now();
    TimeOfDay timeTiba = isEdit 
        ? TimeOfDay.fromDateTime(DateTime.parse(item['tanggal_kedatangan'])) 
        : TimeOfDay(hour: (timeBerangkat.hour + 4) % 24, minute: timeBerangkat.minute);

    final hargaCtrl = TextEditingController(text: item?['harga']?.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(isEdit ? "Edit Jadwal" : "Tambah Jadwal"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pilih Kereta", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Consumer<AdminProvider>(
                  builder: (context, provider, _) {
                    final keretaList = provider.listKereta ?? [];
                    return DropdownButtonFormField<String>(
                      value: keretaList.any((k) => k['id'].toString() == selectedKereta) 
                          ? selectedKereta 
                          : null,
                      isExpanded: true,
                      hint: const Text("Pilih Kereta"),
                      items: keretaList.map<DropdownMenuItem<String>>((k) {
                        return DropdownMenuItem(
                          value: k['id'].toString(),
                          child: Text(k['nama_kereta'] ?? ""),
                        );
                      }).toList(),
                      onChanged: (v) => setLocalState(() => selectedKereta = v),
                    );
                  },
                ),
                const SizedBox(height: 15),

                const Text("Rute Keberangkatan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: stations.contains(asal) ? asal : stations[0],
                        items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (v) => setLocalState(() => asal = v!),
                        decoration: const InputDecoration(labelText: "Asal"),
                      ),
                    ),
                    const Icon(Icons.arrow_right_alt),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: stations.contains(tujuan) ? tujuan : stations[1],
                        items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (v) => setLocalState(() => tujuan = v!),
                        decoration: const InputDecoration(labelText: "Tujuan"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Date & Time pickers 
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Tanggal: ${DateFormat('yyyy-MM-dd').format(date)}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime(2030));
                    if (d != null) setLocalState(() => date = d);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        child: Text("Pergi: ${timeBerangkat.format(context)}"),
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: timeBerangkat);
                          if (t != null) setLocalState(() => timeBerangkat = t);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        child: Text("Tiba: ${timeTiba.format(context)}"),
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: timeTiba);
                          if (t != null) setLocalState(() => timeTiba = t);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(controller: hargaCtrl, decoration: const InputDecoration(labelText: "Harga Tiket", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (selectedKereta == null || hargaCtrl.text.isEmpty) return;
                final provider = Provider.of<AdminProvider>(context, listen: false);
                
                String dtBerangkat = "${DateFormat('yyyy-MM-dd').format(date)} ${timeBerangkat.hour.toString().padLeft(2, '0')}:${timeBerangkat.minute.toString().padLeft(2, '0')}:00";
                String dtTiba = "${DateFormat('yyyy-MM-dd').format(date)} ${timeTiba.hour.toString().padLeft(2, '0')}:${timeTiba.minute.toString().padLeft(2, '0')}:00";

                final Map<String, dynamic> body = {
                  'id_kereta': selectedKereta,
                  'asal_keberangkatan': asal,
                  'tujuan_keberangkatan': tujuan,
                  'tanggal_berangkat': dtBerangkat,
                  'tanggal_kedatangan': dtTiba,
                  'harga': hargaCtrl.text,
                };

                bool success = isEdit 
                    ? await provider.updateJadwal(item['id'].toString(), body) 
                    : await provider.addJadwal(body);

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan")));
                }
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Jadwal")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.getJadwal(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.listJadwal.length,
                itemBuilder: (context, index) {
                  final item = provider.listJadwal[index];
                  return CrudTemplateView(
                    title: "${item['asal_keberangkatan']} -> ${item['tujuan_keberangkatan']}",
                    subtitle: "KA: ${item['nama_kereta']}\nBerangkat: ${item['tanggal_berangkat']}",
                    trailingText: "Rp ${item['harga']}",
                    onEdit: () => _showFormDialog(item: item),
                   onDelete: () async {
  final String idToDelete = item['id'].toString(); 
  
  final result = await provider.deleteJadwal(idToDelete);
  
  if (!mounted) return;

  // pesan berhasil atau gagal
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result['message']),
      backgroundColor: result['success'] ? Colors.green : Colors.red,
    ),
  );
},
                  );
                },
              ),
            ),
    );
  }
}