import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

const String baseUrl = "https://micke.my.id/api/ukk";

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  UserModel? _currentUser;
  List<dynamic> _listRiwayat = [];

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  List<dynamic> get listRiwayat => _listRiwayat;

  // LOGIN
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'username': username, 'password': password},
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        // Parse using the new robust UserModel
        _currentUser = UserModel.fromJson(data['data']);

        // === CRITICAL: SAVE SESSION TO PHONE ===
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _currentUser?.id?.toString() ?? '');
        await prefs.setString('role', _currentUser?.role ?? 'penumpang');
        
        // SAVE PROFILE DATA SO IT DOESN'T DISAPPEAR
        await prefs.setString('nama', _currentUser?.namaLengkap ?? '');
        await prefs.setString('nik', _currentUser?.nik ?? '');
        await prefs.setString('telp', _currentUser?.telp ?? '');
        await prefs.setString('idPelanggan', _currentUser?.idPelanggan?.toString() ?? '');
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("Login Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('isLoggedIn')) return false;

    // Load data back from phone storage
    _currentUser = UserModel(
      id: int.tryParse(prefs.getString('userId') ?? '0'),
      role: prefs.getString('role'),
      idPelanggan: int.tryParse(prefs.getString('idPelanggan') ?? '0'),
      namaLengkap: prefs.getString('nama'), // Load Name
      nik: prefs.getString('nik'),          // Load NIK
      telp: prefs.getString('telp'),        // Load Telp
    );
    
    notifyListeners();
    return true;
  }

  // 3. LOGOUT
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // 4. BOOKING TICKET (Keep your existing working logic)
  Future<bool> bookTicket({required String idJadwal, required List<Map<String, String>> passengers}) async {
    _isLoading = true;
    notifyListeners();
    try {
      String idPelangganStr = _currentUser?.idPelanggan?.toString() ?? '';
      // Fallback to prefs if memory is empty
      if (idPelangganStr.isEmpty || idPelangganStr == "0" || idPelangganStr == "null") {
         final prefs = await SharedPreferences.getInstance();
         idPelangganStr = prefs.getString('idPelanggan') ?? '';
      }

      Map<String, String> body = {
        'id_pelanggan': idPelangganStr, 
        'id_jadwal': idJadwal,
      };

      for (int i = 0; i < passengers.length; i++) {
        body['penumpang[$i][nik]'] = passengers[i]['nik']!;
        body['penumpang[$i][nama]'] = passengers[i]['nama']!;
        body['penumpang[$i][id_kursi]'] = passengers[i]['id_kursi']!;
        body['penumpang[$i][id_gerbong]'] = passengers[i]['id_gerbong']!;
      }

      final response = await http.post(Uri.parse('$baseUrl/booking.php'), body: body);
      final data = json.decode(response.body);
      _isLoading = false;
      notifyListeners();

      if (data['status'] == 'success' || data['message'].toString().toLowerCase().contains('berhasil')) {
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}