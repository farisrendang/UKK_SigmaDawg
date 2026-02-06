import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'crud_template_view.dart'; // Template Item List

class UniversalCrudView extends StatefulWidget {
  const UniversalCrudView({super.key});

  @override
  State<UniversalCrudView> createState() => _UniversalCrudViewState();
}

class _UniversalCrudViewState extends State<UniversalCrudView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getKereta();
    });
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final namaCtrl = TextEditingController(text: item?['nama_kereta']);
    final deskripsiCtrl = TextEditingController(text: item?['deskripsi']);
    final kelasCtrl = TextEditingController(text: item?['kelas']);
    // Parameter tambahan sesuai provider baru
    final jmlGerbongCtrl = TextEditingController(text: item?['jumlah_gerbong']?.toString());
    final kuotaCtrl = TextEditingController(text: item?['kuota']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Kereta" : "Tambah Kereta"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Kereta")),
              TextField(controller: deskripsiCtrl, decoration: const InputDecoration(labelText: "Deskripsi")),
              TextField(controller: kelasCtrl, decoration: const InputDecoration(labelText: "Kelas (Eko/Bisnis/Eks)")),
              TextField(controller: jmlGerbongCtrl, decoration: const InputDecoration(labelText: "Jumlah Gerbong"), keyboardType: TextInputType.number),
              TextField(controller: kuotaCtrl, decoration: const InputDecoration(labelText: "Kuota per Gerbong"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AdminProvider>(context, listen: false);
              bool success;
              
              if (isEdit) {
                // Update
                success = await provider.updateKereta(
                  item['id_kereta'].toString(), // Pastikan key ID sesuai API
                  namaCtrl.text,
                  deskripsiCtrl.text,
                  kelasCtrl.text,
                  jmlGerbongCtrl.text,
                );
              } else {
                // Add
                success = await provider.addKereta(
                  namaCtrl.text,
                  deskripsiCtrl.text,
                  kelasCtrl.text,
                  jmlGerbongCtrl.text,
                  kuotaCtrl.text,
                );
              }

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan")));
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
      appBar: AppBar(title: const Text("Manajemen Kereta")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.listKereta.length,
            itemBuilder: (context, index) {
              final item = provider.listKereta[index];
              return CrudTemplateView(
                title: item['nama_kereta'] ?? '-',
                subtitle: "${item['kelas']} - ${item['deskripsi']}",
                trailingText: "${item['jumlah_gerbong'] ?? 0} Gerbong",
                onEdit: () => _showFormDialog(item: item),
                onDelete: () async {
                   await provider.deleteKereta(item['id_kereta'].toString());
                },
              );
            },
          ),
    );
  }
}