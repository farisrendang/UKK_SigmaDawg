import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
const String baseUrl = "https://micke.my.id/api/ukk";

class AuthProvider with ChangeNotifier {
  // Base URL API
  static const String baseUrl = "https://micke.my.id/api/ukk";

  bool _isLoading = false;
  UserModel? _currentUser;
  
  // Variabel untuk menyimpan data riwayat tiket
  List<dynamic> _listRiwayat = [];

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  List<dynamic> get listRiwayat => _listRiwayat;

  // ===========================================================================
  // 1. REGISTER PELANGGAN
  // ===========================================================================
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String nik,
    required String namaPenumpang,
    required String alamat,
    required String telp,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/register.php');
      
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'nama_penumpang': namaPenumpang,
          'nik': nik,
          'telp': telp,
          'alamat': alamat,
        },
      );

      final data = json.decode(response.body);
      _isLoading = false;
      notifyListeners();
      return data; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': false, 'message': 'Koneksi Error: $e'};
    }
  }

  // ===========================================================================
  // 2. LOGIN (USER & ADMIN)
  // ===========================================================================
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/login.php');
      
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      print("Response Login: ${response.body}"); // Debugging

      final data = json.decode(response.body);

      // Cek status success
      if (data['status'] == 'success') {
        final userData = data['data']; 
        
        // Parsing ke Model
        _currentUser = UserModel.fromJson(userData);

        // Simpan sesi ke HP (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', _currentUser!.role);
        // Simpan ID user untuk keperluan pengambilan data nanti
        await prefs.setString('userId', _currentUser!.id); 
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error Login: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // 3. LOGOUT
  // ===========================================================================
  Future<void> logout() async {
    _currentUser = null;
    _listRiwayat = []; // Kosongkan riwayat saat logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data sesi
    notifyListeners();
  }

  // ===========================================================================
  // 4. BOOKING TICKET (MULTI PENUMPANG)
  // Format Array: penumpang[0][nik], penumpang[0][nama], dst.
  // ===========================================================================
  Future<bool> bookTicket({
    required String idJadwal,
    required List<Map<String, String>> passengers, // List data penumpang
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/booking.php');

      // 1. Siapkan Body Dasar
      Map<String, String> body = {
        'id_pelanggan': _currentUser?.id ?? '', // Ambil ID user yang sedang login
        'id_jadwal': idJadwal,
      };

      // 2. Loop passengers untuk membuat Key Array ala PHP
      for (int i = 0; i < passengers.length; i++) {
        body['penumpang[$i][nik]'] = passengers[i]['nik']!;
        body['penumpang[$i][nama]'] = passengers[i]['nama']!;
        body['penumpang[$i][id_kursi]'] = passengers[i]['id_kursi']!;
        body['penumpang[$i][id_gerbong]'] = passengers[i]['id_gerbong']!;
      }

      print("Sending Booking Data: $body"); // Debugging body request

      final response = await http.post(url, body: body);
      final data = json.decode(response.body);

      _isLoading = false;
      notifyListeners();

      if (data['status'] == 'success' || data['message'].toString().toLowerCase().contains('berhasil')) {
        // Jika berhasil, refresh data riwayat agar update
        await getRiwayat(); 
        return true;
      }
      return false;

    } catch (e) {
      print("Error Booking: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // 5. GET RIWAYAT TIKET
  // Mengambil daftar tiket berdasarkan ID Pelanggan yang login
  // ===========================================================================
  Future<void> getRiwayat() async {
    // Jangan set loading true jika hanya refresh background, 
    // tapi untuk awal boleh true.
    _isLoading = true; 
    notifyListeners();

    try {
      final idUser = _currentUser?.id ?? '';
      
      // Pastikan API Anda mendukung parameter id_pelanggan
      final url = Uri.parse('$baseUrl/riwayat.php?id_pelanggan=$idUser'); 
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listRiwayat = data['data'];
      } else {
        _listRiwayat = [];
      }
    } catch (e) {
      print("Error Get Riwayat: $e");
      _listRiwayat = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}