import 'package:flutter/material.dart';
import 'package:ukk_percobaan2/services/auth_service.dart';
import 'package:ukk_percobaan2/widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isObscure = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaPenumpangController =
      TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  void _handleRegister() async {
    // 1. Ambil Data
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final nama = _namaPenumpangController.text.trim();
    final nik = _nikController.text.trim();
    final telp = _telpController.text.trim();
    final alamat = _alamatController.text.trim();

    // 2. Validasi
    if (username.isEmpty ||
        password.isEmpty ||
        nama.isEmpty ||
        nik.isEmpty ||
        telp.isEmpty ||
        alamat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Kirim ke API
    final result = await _authService.register({
      'username': username,
      'password': password,
      'nama_penumpang': nama,
      'nik': nik,
      'telp': telp,
      'alamat': alamat,
    });

    if (!mounted) return;

    setState(() => _isLoading = false);

    // 4. Cek Hasil
    if (result['success'] == true) {
      // SUKSES -> Tampilkan Pesan -> Kembali ke Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // GAGAL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Akun Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Lengkapi data diri",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                label: "Username",
                prefixIcon: Icons.alternate_email,
                controller: _usernameController,
              ),
              CustomTextField(
                label: "Password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscure,
                controller: _passwordController,
                onToggleVisibility:
                    () => setState(() => _isObscure = !_isObscure),
              ),
              CustomTextField(
                label: "Nama Penumpang",
                prefixIcon: Icons.person_outline,
                controller: _namaPenumpangController,
              ),
              CustomTextField(
                label: "NIK",
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
                controller: _nikController,
              ),
              CustomTextField(
                label: "Nomor Telepon",
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                controller: _telpController,
              ),
              CustomTextField(
                label: "Alamat Lengkap",
                prefixIcon: Icons.home_outlined,
                controller: _alamatController,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "DAFTAR SEKARANG",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
