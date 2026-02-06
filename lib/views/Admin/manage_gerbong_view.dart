import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'crud_template_view.dart';
// Hapus import admin_provider jika tidak dipakai untuk ambil baseUrl
// import '../../providers/admin_provider.dart'; 

class ManageGerbongView extends StatefulWidget {
  const ManageGerbongView({super.key});

  @override
  State<ManageGerbongView> createState() => _ManageGerbongViewState();
}

class _ManageGerbongViewState extends State<ManageGerbongView> {
  // DEFINE BASE URL LOKAL DISINI (Agar tidak error minta ke AdminProvider)
  final String baseUrl = "https://micke.my.id/api/ukk";

  bool _isLoading = false;
  List<dynamic> _listGerbong = [];

  @override
  void initState() {
    super.initState();
    _getGerbong();
  }

  // 1. FUNGSI GET GERBONG (LOKAL)
  Future<void> _getGerbong() async {
    setState(() => _isLoading = true);
    try {
      // Gunakan variabel baseUrl lokal
      final response = await http.get(Uri.parse('$baseUrl/gerbong.php'));
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        setState(() {
          _listGerbong = data['data'];
        });
      }
    } catch (e) {
      print("Error Get Gerbong: $e");
    }
    setState(() => _isLoading = false);
  }

  // 2. FUNGSI ADD GERBONG (LOKAL)
  Future<bool> _addGerbong(String namaGerbong, String kuota, String idKereta) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gerbong.php'),
        body: {
          'nama_gerbong': namaGerbong,
          'kuota': kuota,
          'id_kereta': idKereta
        },
      );
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        await _getGerbong(); // Refresh list setelah tambah
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Tampilkan Dialog Form
  void _showFormDialog() {
    final namaCtrl = TextEditingController();
    final kuotaCtrl = TextEditingController();
    final idKeretaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Gerbong"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Gerbong (cth: Eksekutif 1)")),
            TextField(controller: kuotaCtrl, decoration: const InputDecoration(labelText: "Kuota Kursi"), keyboardType: TextInputType.number),
            TextField(controller: idKeretaCtrl, decoration: const InputDecoration(labelText: "ID Kereta"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || kuotaCtrl.text.isEmpty || idKeretaCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi semua data!")));
                return;
              }

              final success = await _addGerbong(namaCtrl.text, kuotaCtrl.text, idKeretaCtrl.text);
              
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gerbong Berhasil Ditambah")));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambah data")));
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
    return Scaffold(
      appBar: AppBar(title: const Text("Data Gerbong")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listGerbong.isEmpty 
              ? const Center(child: Text("Belum ada data gerbong"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listGerbong.length,
                  itemBuilder: (context, index) {
                    final item = _listGerbong[index];
                    return CrudTemplateView(
                      title: item['nama_gerbong'] ?? '-',
                      subtitle: "ID Kereta: ${item['id_kereta']}",
                      trailingText: "${item['kuota']} Kursi",
                      onEdit: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit belum diimplementasikan")));
                      }, 
                      onDelete: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Hapus belum diimplementasikan")));
                      }, 
                    );
                  },
                ),
    );
  }
}