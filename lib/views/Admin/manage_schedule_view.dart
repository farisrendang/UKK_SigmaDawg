import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'crud_template_view.dart';

class ManageScheduleView extends StatefulWidget {
  const ManageScheduleView({super.key});

  @override
  State<ManageScheduleView> createState() => _ManageScheduleViewState();
}

class _ManageScheduleViewState extends State<ManageScheduleView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getJadwal();
    });
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final idKeretaCtrl = TextEditingController(text: item?['id_kereta']?.toString());
    final asalCtrl = TextEditingController(text: item?['asal_keberangkatan']);
    final tujuanCtrl = TextEditingController(text: item?['tujuan_keberangkatan']);
    final tglBerangkatCtrl = TextEditingController(text: item?['tanggal_berangkat']);
    final tglDatangCtrl = TextEditingController(text: item?['tanggal_kedatangan']);
    final hargaCtrl = TextEditingController(text: item?['harga']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Jadwal" : "Tambah Jadwal"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: idKeretaCtrl, decoration: const InputDecoration(labelText: "ID Kereta")),
              TextField(controller: asalCtrl, decoration: const InputDecoration(labelText: "Asal (Kota)")),
              TextField(controller: tujuanCtrl, decoration: const InputDecoration(labelText: "Tujuan (Kota)")),
              TextField(controller: tglBerangkatCtrl, decoration: const InputDecoration(labelText: "Waktu Berangkat (YYYY-MM-DD HH:MM:SS)")),
              TextField(controller: tglDatangCtrl, decoration: const InputDecoration(labelText: "Waktu Tiba (YYYY-MM-DD HH:MM:SS)")),
              TextField(controller: hargaCtrl, decoration: const InputDecoration(labelText: "Harga Tiket"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AdminProvider>(context, listen: false);
              
              // Siapkan Map Body sesuai Provider
              final Map<String, dynamic> body = {
                'id_kereta': idKeretaCtrl.text,
                'asal_keberangkatan': asalCtrl.text,
                'tujuan_keberangkatan': tujuanCtrl.text,
                'tanggal_berangkat': tglBerangkatCtrl.text,
                'tanggal_kedatangan': tglDatangCtrl.text,
                'harga': hargaCtrl.text,
              };

              bool success;
              if (isEdit) {
                success = await provider.updateJadwal(item['id_jadwal'].toString(), body);
              } else {
                success = await provider.addJadwal(body);
              }

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jadwal Berhasil Disimpan")));
              }
            },
            child: const Text("Simpan"),
          )
        ],
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
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.listJadwal.length,
              itemBuilder: (context, index) {
                final item = provider.listJadwal[index];
                return CrudTemplateView(
                  title: "${item['asal_keberangkatan']} -> ${item['tujuan_keberangkatan']}",
                  subtitle: "Berangkat: ${item['tanggal_berangkat']}",
                  trailingText: "Rp ${item['harga']}",
                  onEdit: () => _showFormDialog(item: item),
                  onDelete: () async {
                    await provider.deleteJadwal(item['id_jadwal'].toString());
                  },
                );
              },
            ),
    );
  }
}