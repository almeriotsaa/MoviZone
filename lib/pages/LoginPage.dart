import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_app/pages/RegisterPage.dart';
import 'package:movie_app/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      print("--- MULAI PROSES LOGIN ---");
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");

      try {
        // PASTIKAN IP INI BENAR! Cek CMD > ipconfig
        final url = Uri.parse("http://192.168.1.17/MOVIZONE_API/auth/login.php");

        final response = await http.post(
          url,
          body: {
            "email": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          },
        ).timeout(const Duration(seconds: 10));

        print("--- RESPON DITERIMA ---");
        print("Status Code: ${response.statusCode}");
        print("Isi Body: ${response.body}"); // CEK DI CONSOLE VS CODE!

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['status'] == 'success') {
            // AMBIL USER ID (Sesuaikan dengan file PHP kamu)
            // PHP kamu kirim "user_id"
            String loggedInUserId = data['user_id'].toString();

            print("LOGIN BERHASIL! User ID: $loggedInUserId");

            if (mounted) {
              setState(() => _isLoading = false);

              // PINDAH HALAMAN
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(userId: loggedInUserId),
                ),
              );
            }
          } else {
            print("LOGIN GAGAL: ${data['message']}");
            _showError(data['message'] ?? "Email atau Password Salah");
          }
        } else {
          print("SERVER ERROR: ${response.statusCode}");
          _showError("Server Error: ${response.statusCode}");
        }
      } catch (e) {
        print("--- ERROR TOTAL ---");
        print("Pesan Error: $e"); // LIHAT DI SINI KALAU KONEKSI PUTUS
        _showError("Gagal terhubung ke server. Cek IP/Wi-Fi!");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi pembantu buat nampilin error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ CHANGED: Colors.black → scaffold dark navy
      backgroundColor: const Color(0xFF0D0F14),
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.0,
                colors: [
                  // ✅ CHANGED: Color(0xFF0D1B2A) → surface variant biru gelap
                  Color(0xFF111827),
                  // ✅ CHANGED: Color(0xFF000000) → scaffold dark navy
                  Color(0xFF0D0F14),
                ],
              ),
            ),
          ),

          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ CHANGED: Colors.lightBlueAccent.withOpacity(0.05) → primary blue
                color: const Color(0xFF2979FF).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ CHANGED: Colors.lightBlueAccent.withOpacity(0.04) → primary blue
                color: const Color(0xFF2979FF).withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // ✅ CHANGED: Color(0xFF1E1E2C) → surface card
                                color: const Color(0xFF161A22),
                                boxShadow: [
                                  BoxShadow(
                                    // ✅ CHANGED: Colors.lightBlueAccent.withOpacity(0.3) → primary blue
                                    color: const Color(0xFF2979FF).withOpacity(0.25),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  // ✅ CHANGED: Colors.lightBlueAccent.withOpacity(0.5) → primary blue
                                  color: const Color(0xFF2979FF).withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.movie_filter_rounded,
                                // ✅ CHANGED: Colors.lightBlueAccent → primary blue
                                color: Color(0xFF2979FF),
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 14),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Movi',
                                    style: TextStyle(
                                      // ✅ CHANGED: Colors.white → text primary
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Z',
                                    style: TextStyle(
                                      // ✅ CHANGED: Colors.lightBlueAccent → primary blue
                                      color: Color(0xFF2979FF),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'One',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        'Welcome Back 👋',
                        style: TextStyle(
                          // ✅ CHANGED: Colors.white → text primary
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Login to continue',
                        style: TextStyle(
                          // ✅ CHANGED: Colors.white54 → text secondary
                          color: Color(0xFF9AA3B8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              // ✅ CHANGED: Colors.white → text primary
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: _inputDecoration(
                                hint: 'example@email.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value.trim())) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: _inputDecoration(
                                hint: 'Minimum 6 characters',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    // ✅ CHANGED: Colors.white38 → text hint
                                    color: const Color(0xFF4A5568),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password cannot be empty';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 36),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  // ✅ CHANGED: Colors.lightBlueAccent → primary blue
                                  backgroundColor: const Color(0xFF2979FF),
                                  // ✅ CHANGED: Colors.lightBlueAccent.withOpacity(0.5) → primary blue redup
                                  disabledBackgroundColor:
                                  const Color(0xFF2979FF).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    // ✅ CHANGED: Colors.black → putih (kontras di bg biru)
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(
                                    // ✅ CHANGED: Colors.black → putih
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    // ✅ CHANGED: Colors.white54 → text secondary
                                    color: Color(0xFF9AA3B8),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        transitionDuration:
                                        const Duration(milliseconds: 400),
                                        pageBuilder: (_, __, ___) =>
                                        const RegisterPage(),
                                        transitionsBuilder:
                                            (_, animation, __, child) =>
                                            SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      // ✅ CHANGED: Colors.lightBlueAccent → primary blue
                                      color: Color(0xFF2979FF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          // ✅ CHANGED: Colors.white70 → text secondary
          color: Color(0xFF9AA3B8),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      // ✅ CHANGED: Colors.white24 → text hint
      hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
      // ✅ CHANGED: Colors.white38 → text hint
      prefixIcon: Icon(icon, color: const Color(0xFF4A5568), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      // ✅ CHANGED: Color(0xFF1E1E2C) → surface card
      fillColor: const Color(0xFF161A22),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: Colors.white.withOpacity(0.06) → border palette
        borderSide: const BorderSide(
          color: Color(0xFF252B38),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: Colors.lightBlueAccent → primary blue
        borderSide: const BorderSide(
          color: Color(0xFF2979FF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: Colors.redAccent → merah lebih dalam
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFE53935), fontSize: 12),
    );
  }
}