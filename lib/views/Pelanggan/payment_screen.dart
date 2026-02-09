import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';

class PaymentScreen extends StatefulWidget {
  final int idPembelian;
  final int totalHarga;

  const PaymentScreen({super.key, required this.idPembelian, required this.totalHarga});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = "Transfer Bank";
  final List<String> _methods = ["Transfer Bank", "E-Wallet", "Kartu Kredit", "Minimarket"];

  void _pay() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    
    bool success = await provider.processPayment(widget.idPembelian, _selectedMethod);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Pembayaran berhasil dikonfirmasi!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(c); // Close Dialog
                Navigator.pop(context); // Go Back to History
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses pembayaran"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedPrice = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.totalHarga);

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran"), backgroundColor: const Color(0xFFC2185B)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Tagihan", style: TextStyle(color: Colors.grey)),
            Text(formattedPrice, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
            const SizedBox(height: 30),
            const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._methods.map((m) => RadioListTile(
              title: Text(m),
              value: m,
              groupValue: _selectedMethod,
              activeColor: const Color(0xFFC2185B),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _pay,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2185B)),
                child: const Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}