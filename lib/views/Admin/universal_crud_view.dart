import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'crud_template_view.dart'; // Ensure this file exists in your project

class UniversalCrudView extends StatefulWidget {
  const UniversalCrudView({super.key});

  @override
  State<UniversalCrudView> createState() => _UniversalCrudViewState();
}

class _UniversalCrudViewState extends State<UniversalCrudView> {
  @override
  void initState() {
    super.initState();
    // Fetch data immediately when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getKereta();
    });
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;

    // SAFE DATA LOADING:
    // We check multiple keys to ensure we get the number if it exists
    final initialGerbong =
        item?['jumlah_gerbong'] ?? item?['jumlah_gerbong_aktif'];

    final namaCtrl = TextEditingController(text: item?['nama_kereta']);
    final deskripsiCtrl = TextEditingController(text: item?['deskripsi']);
    final kelasCtrl = TextEditingController(text: item?['kelas']);
    final jmlGerbongCtrl = TextEditingController(
      text: initialGerbong?.toString(),
    );
    final kuotaCtrl = TextEditingController(text: item?['kuota']?.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? "Edit Kereta" : "Tambah Kereta"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaCtrl,
                    decoration: const InputDecoration(labelText: "Nama Kereta"),
                  ),
                  TextField(
                    controller: deskripsiCtrl,
                    decoration: const InputDecoration(labelText: "Deskripsi"),
                  ),
                  TextField(
                    controller: kelasCtrl,
                    decoration: const InputDecoration(
                      labelText: "Kelas (Eko/Bisnis/Eks)",
                    ),
                  ),
                  TextField(
                    controller: jmlGerbongCtrl,
                    decoration: const InputDecoration(
                      labelText: "Jumlah Gerbong",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: kuotaCtrl,
                    decoration: const InputDecoration(
                      labelText: "Kuota per Gerbong",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  );
                  bool success;

                  if (isEdit) {
                    // Update Logic
                    // Ensure 'id_kereta' matches your DB ID key exactly
                    success = await provider.updateKereta(
                      item!['id_kereta'].toString(),
                      namaCtrl.text,
                      deskripsiCtrl.text,
                      kelasCtrl.text,
                      jmlGerbongCtrl.text,
                    );
                  } else {
                    // Add Logic
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil disimpan")),
                    );
                    // Refresh data to show changes immediately
                    provider.getKereta();
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes efficiently
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Manajemen Kereta")),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showFormDialog(),
            child: const Icon(Icons.add),
          ),
          body:
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.listKereta.length,
                    itemBuilder: (context, index) {
                      final item = provider.listKereta[index];

                      // DEBUG: Check your console to see exactly what the data is
                      print("DEBUG DATA: $item");

                      // LOGIC FIX:
                      // 1. Check 'jumlah_gerbong_aktif' FIRST (Priority)
                      // 2. If that is missing, try 'jumlah_gerbong'
                      // 3. If both fail, use 0
                      final gerbongCount =
                          item['jumlah_gerbong_aktif'] ??
                          item['jumlah_gerbong'] ??
                          0;

                      return CrudTemplateView(
                        title: item['nama_kereta'] ?? '-',
                        subtitle: "${item['kelas']} - ${item['deskripsi']}",
                        trailingText: "$gerbongCount Gerbong",
                        onEdit: () => _showFormDialog(item: item),
                        onDelete: () async {
                          // Ensure 'id_kereta' is the correct key (or try 'id')
                          await provider.deleteKereta(
                            item['id_kereta'].toString(),
                          );
                        },
                      );
                    },
                  ),
        );
      },
    );
  }
}
