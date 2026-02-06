import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base URL API
  static const String baseUrl = "https://micke.my.id/api/ukk";

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'username': username,
          'password': password,
        },
      );

      print("LOGIN RAW: ${response.body}"); // Debugging di Terminal

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cek sukses (Support berbagai format respon API)
        bool isSuccess = data['status'] == true || 
                         data['success'] == true || 
                         (data['message'] != null && data['message'].toString().toLowerCase().contains('berhasil'));

        if (isSuccess) {
          String token = data['token'] ?? 'dummy_token';
          String role = data['role'] ?? 'pelanggan'; // Default pelanggan jika API tidak kirim role

          await _saveUserSession(token, role);

          return {
            'success': true,
            'role': role,
            'message': data['message'] ?? 'Login Berhasil'
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Username atau Password Salah'
          };
        }
      } else {
        return {'success': false, 'message': 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Gagal: Pastikan Internet Aktif'};
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: data,
      );

      print("REGISTER RAW: ${response.body}"); // Debugging di Terminal

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Logika Cek Sukses
        bool isSuccess = result['status'] == true || 
                         result['success'] == true || 
                         (result['message'] != null && result['message'].toString().toLowerCase().contains('berhasil'));

        if (isSuccess) {
          return {
            'success': true, 
            'message': result['message'] ?? 'Registrasi Berhasil'
          };
        } else {
          return {
            'success': false, 
            'message': result['message'] ?? 'Gagal Mendaftar'
          };
        }
      } else {
        return {'success': false, 'message': 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Gagal: $e'};
    }
  }

  // Simpan Sesi di HP
  Future<void> _saveUserSession(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
  }

  // Hapus Sesi (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Cek Token (Login Otomatis)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}