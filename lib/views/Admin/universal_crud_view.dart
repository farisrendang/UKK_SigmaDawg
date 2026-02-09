import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'crud_template_view.dart';

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

    final initialGerbong =
        item?['jumlah_gerbong'] ?? item?['jumlah_gerbong_aktif'];

    final namaCtrl = TextEditingController(text: item?['nama_kereta']);
    final deskripsiCtrl = TextEditingController(text: item?['deskripsi']);
    final kelasCtrl = TextEditingController(text: item?['kelas']);
    final jmlGerbongCtrl = TextEditingController(
      text: initialGerbong?.toString(),
    );
    final kuotaCtrl = TextEditingController(
      text: item?['kuota']?.toString() ?? '50',
    );

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
                    success = await provider.updateKereta(
                      item!['id'].toString(), 
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
                    provider.getKereta();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gagal menyimpan data"),
                        backgroundColor: Colors.red,
                      ),
                    );
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

                      print("DEBUG DATA: $item");

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
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text("Hapus Kereta?"),
                                  content: const Text(
                                    "Seluruh data gerbong dan kursi terkait akan ikut terhapus.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Hapus",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            final String idKereta = item['id'].toString();

                            final resultMessage = await provider.deleteKereta(
                              idKereta,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(resultMessage),
                                  backgroundColor:
                                      resultMessage.contains("success") ||
                                              resultMessage.contains("berhasil")
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
        );
      },
    );
  }
}