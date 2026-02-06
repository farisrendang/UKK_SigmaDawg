// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ukk_percobaan2/providers/auth_provider.dart';
// import 'package:ukk_percobaan2/widgets/custom_text_field.dart';
// import 'seat_selection_view.dart'; // Pastikan file ini ada

// class BookingView extends StatefulWidget {
//   final Map<String, dynamic> schedule; // Data jadwal dari Home

//   const BookingView({super.key, required this.schedule});

//   @override
//   State<BookingView> createState() => _BookingViewState();
// }

// class _BookingViewState extends State<BookingView> {
//   // Default jumlah penumpang 1
//   int _passengerCount = 1;

//   // List Dinamis untuk Input NIK dan Nama
//   List<TextEditingController> nikControllers = [];
//   List<TextEditingController> nameControllers = [];
  
//   // List Dinamis untuk menyimpan kursi terpilih per penumpang
//   List<Map<String, dynamic>?> selectedSeats = [];

//   @override
//   void initState() {
//     super.initState();
//     _updateControllers(); // Inisialisasi awal controller
//   }

//   @override
//   void dispose() {
//     // Bersihkan controller saat halaman ditutup agar hemat memori
//     for (var controller in nikControllers) {
//       controller.dispose();
//     }
//     for (var controller in nameControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   // Fungsi menambah/mengurangi form sesuai jumlah penumpang
//   void _updateControllers() {
//     while (nikControllers.length < _passengerCount) {
//       nikControllers.add(TextEditingController());
//       nameControllers.add(TextEditingController());
//       selectedSeats.add(null);
//     }
//     while (nikControllers.length > _passengerCount) {
//       nikControllers.last.dispose();
//       nameControllers.last.dispose();
//       nikControllers.removeLast();
//       nameControllers.removeLast();
//       selectedSeats.removeLast();
//     }
//   }

//   void _handleBooking() async {
//     // 1. Validasi Input Kosong
//     for (int i = 0; i < _passengerCount; i++) {
//       if (nikControllers[i].text.trim().isEmpty || nameControllers[i].text.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Mohon lengkapi NIK dan Nama Penumpang ${i + 1}!"))
//         );
//         return;
//       }
//       if (selectedSeats[i] == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Silakan pilih kursi untuk Penumpang ${i + 1}!"))
//         );
//         return;
//       }
//     }

//     // 2. Susun Data Penumpang (Fix Error Merah Tipe Data)
//     // Kita paksa semua value menjadi String agar sesuai dengan List<Map<String, String>>
//     List<Map<String, String>> passengersData = [];
    
//     for (int i = 0; i < _passengerCount; i++) {
//       passengersData.add({
//         'nik': nikControllers[i].text.trim(),
//         'nama': nameControllers[i].text.trim(),
//         // PENTING: Tambahkan .toString() agar tipe datanya pasti String
//         'id_kursi': selectedSeats[i]!['id_kursi'].toString(),
//         'id_gerbong': selectedSeats[i]!['id_gerbong'].toString(),
//       });
//     }

//     // 3. Panggil Provider
//     // listen: false wajib digunakan saat memanggil fungsi di dalam event handler
//     final success = await Provider.of<AuthProvider>(context, listen: false).bookTicket(
//       idJadwal: widget.schedule['id_jadwal'].toString(), // Pastikan ID Jadwal String
//       passengers: passengersData,
//     );

//     if (!mounted) return;

//     if (success) {
//       // Tampilkan Dialog Sukses
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (c) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Column(
//             children: const [
//               Icon(Icons.check_circle, color: Colors.green, size: 60),
//               SizedBox(height: 10),
//               Text("Berhasil!", style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: const Text(
//             "Tiket berhasil dipesan.\nSilakan cek tiket Anda di menu 'Tiket Saya'.",
//             textAlign: TextAlign.center,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(c); // Tutup Dialog
//                 Navigator.pop(context); // Kembali ke Home
//               }, 
//               child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold))
//             )
//           ],
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Gagal memesan tiket. Silakan coba lagi."), 
//           backgroundColor: Colors.red
//         )
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Mengambil status loading dari provider
//     final isLoading = context.watch<AuthProvider>().isLoading;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Isi Data Penumpang"),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black, // Warna text & icon AppBar
//         titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             // --- INFO PERJALANAN ---
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFC2185B).withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFC2185B).withOpacity(0.2)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//                     child: const Icon(Icons.train, color: Color(0xFFC2185B), size: 30),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${widget.schedule['asal_keberangkatan']} ➝ ${widget.schedule['tujuan_keberangkatan']}", 
//                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                         const SizedBox(height: 4),
//                         Text("Jadwal: ${widget.schedule['tanggal_berangkat']}", 
//                           style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                         Text("Harga: Rp ${widget.schedule['harga']}", 
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),

//             // --- COUNTER JUMLAH PENUMPANG ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Jumlah Penumpang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300), 
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
//                         onPressed: _passengerCount > 1 ? () {
//                           setState(() {
//                             _passengerCount--;
//                             _updateControllers();
//                           });
//                         } : null,
//                       ),
//                       Text("$_passengerCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       IconButton(
//                         icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC2185B)),
//                         onPressed: () {
//                           setState(() {
//                             _passengerCount++;
//                             _updateControllers();
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),

//             const SizedBox(height: 20),

//             // --- LIST FORM PENUMPANG ---
//             ListView.builder(
//               shrinkWrap: true, // Agar bisa di dalam SingleChildScrollView
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _passengerCount,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 2,
//                   shadowColor: Colors.black12,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Penumpang ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC2185B))),
//                             const Icon(Icons.person, color: Colors.grey, size: 20),
//                           ],
//                         ),
//                         const Divider(height: 24),
                        
//                         // Input NIK (Menggunakan CustomTextField)
//                         CustomTextField(
//                           label: "NIK", 
//                           prefixIcon: Icons.badge_outlined, 
//                           controller: nikControllers[index], 
//                           keyboardType: TextInputType.number
//                         ),
                        
//                         // Input Nama (Menggunakan CustomTextField)
//                         CustomTextField(
//                           label: "Nama Lengkap", 
//                           prefixIcon: Icons.person_outline, 
//                           controller: nameControllers[index]
//                         ),
                        
//                         // Tombol Pilih Kursi
//                         const SizedBox(height: 8),
//                         Container(
//                           width: double.infinity,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: selectedSeats[index] == null ? Colors.grey.shade300 : Colors.green
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             color: selectedSeats[index] == null ? Colors.transparent : Colors.green.withOpacity(0.05),
//                           ),
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () {
//                               // Navigasi ke Halaman Pilih Kursi
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SeatSelectionView(
//                                     // Kirim ID Kereta untuk filter gerbong
//                                     idKereta: widget.schedule['id_kereta'].toString(),
//                                     // Callback: Menangkap data kursi yang dipilih user
//                                     onSeatSelected: (seatData) {
//                                       setState(() {
//                                         selectedSeats[index] = seatData;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   selectedSeats[index] == null ? Icons.event_seat : Icons.check_circle, 
//                                   color: selectedSeats[index] == null ? Colors.grey : Colors.green
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   selectedSeats[index] == null 
//                                       ? "Pilih Kursi" 
//                                       : "Kursi ${selectedSeats[index]!['no_kursi']} (Ganti)",
//                                   style: TextStyle(
//                                     color: selectedSeats[index] == null ? Colors.grey : Colors.green,
//                                     fontWeight: FontWeight.bold
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 20),

//             // --- TOMBOL KONFIRMASI PEMESANAN ---
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : _handleBooking,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFC2185B),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 5,
//                   shadowColor: const Color(0xFFC2185B).withOpacity(0.4),
//                 ),
//                 child: isLoading 
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Konfirmasi Pemesanan", 
//                         style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
//                       ),
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }