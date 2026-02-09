import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:ukk_percobaan2/providers/auth_provider.dart'; 
import 'package:ukk_percobaan2/views/Admin/admin_dashboard_view.dart';
import 'package:ukk_percobaan2/views/Admin/admin_login_view.dart';
import 'package:ukk_percobaan2/widgets/custom_text_field.dart';
import 'home_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan Password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool success = await authProvider.login(username, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      final user = authProvider.currentUser;
      String role = user?.role ?? 'penumpang';

      if (role == 'admin' || role == 'petugas') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const AdminDashboardView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomeView()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Gagal. Periksa username/password."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Color(0xFFC2185B),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masuk untuk melanjutkan perjalananmu",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Form Input
                CustomTextField(
                  label: "Username",
                  prefixIcon: Icons.person_outline,
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

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin, // Calls our fixed function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2185B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "MASUK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Tidak punya akun? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const RegisterView()),
                      ),
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                          color: Color(0xFFC2185B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginView(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text("Halaman Login Khusus Admin"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}