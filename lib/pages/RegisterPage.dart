import 'package:flutter/material.dart';
import 'package:movie_app/pages/LoginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

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
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final url = Uri.parse("http://192.168.1.17/movizone_api/auth/register.php");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            "email": _emailController.text,
            "password": _passwordController.text,
          },
        ).timeout(const Duration(seconds: 10));

        setState(() => _isLoading = false);

        final data = json.decode(response.body);

        const encoder = JsonEncoder.withIndent('  ');
        final prettyData = encoder.convert(data);
        print("API Response:\n$prettyData");

        if (data["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      // ✅ CHANGED: dari Colors.black → putih biar kontras di bg biru gelap
                      color: Colors.white,
                      size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Account created successfully!',
                    style: TextStyle(
                      // ✅ CHANGED: dari Colors.black → putih
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue dari palette
              backgroundColor: const Color(0xFF2979FF),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 2100));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const LoginPage(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(prettyData),
              ),
              // ✅ CHANGED: dari Colors.redAccent → merah yang lebih dalam
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal koneksi ke server: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ CHANGED: dari Colors.black → scaffold dark navy
      backgroundColor: const Color(0xFF0D0F14),
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.0,
                colors: [
                  // ✅ CHANGED: dari Color(0xFF0D1B2A) → surface variant biru gelap
                  Color(0xFF111827),
                  // ✅ CHANGED: dari Color(0xFF000000) → scaffold dark navy
                  Color(0xFF0D0F14),
                ],
              ),
            ),
          ),

          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ CHANGED: dari Colors.lightBlueAccent.withOpacity(0.05) → primary blue
                color: const Color(0xFF2979FF).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ CHANGED: dari Colors.lightBlueAccent.withOpacity(0.04) → primary blue
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
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // ✅ CHANGED: dari Color(0xFF1E1E2C) → surface card
                              color: const Color(0xFF161A22),
                              border: Border.all(
                                // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue
                                color: const Color(0xFF2979FF).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.movie_filter_rounded,
                              // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue
                              color: Color(0xFF2979FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Movi',
                                  style: TextStyle(
                                    // ✅ CHANGED: dari Colors.white → text primary
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Z',
                                  style: TextStyle(
                                    // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue
                                    color: Color(0xFF2979FF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'One',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Create New Account 🎬',
                        style: TextStyle(
                          // ✅ CHANGED: dari Colors.white → text primary
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign up now and start exploring movies',
                        style: TextStyle(
                          // ✅ CHANGED: dari Colors.white54 → text secondary
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
                              // ✅ CHANGED: dari Colors.white → text primary
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: _inputDecoration(
                                hint: 'example@email.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                if (!RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
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
                                    // ✅ CHANGED: dari Colors.white38 → text hint
                                    color: const Color(0xFF4A5568),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
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

                            const SizedBox(height: 20),

                            _buildLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: _inputDecoration(
                                hint: 'Repeat your password',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF4A5568),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm password cannot be empty';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 36),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue
                                  backgroundColor: const Color(0xFF2979FF),
                                  disabledBackgroundColor:
                                  // ✅ CHANGED: dari Colors.lightBlueAccent.withOpacity → primary dark
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
                                    // ✅ CHANGED: dari Colors.black → putih (kontras di bg biru)
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    // ✅ CHANGED: dari Colors.black → putih
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const SizedBox(height: 32),
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
          // ✅ CHANGED: dari Colors.white70 → text secondary
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
      // ✅ CHANGED: dari Colors.white24 → text hint transparan
      hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
      // ✅ CHANGED: dari Colors.white38 → text hint
      prefixIcon: Icon(icon, color: const Color(0xFF4A5568), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      // ✅ CHANGED: dari Color(0xFF1E1E2C) → surface card
      fillColor: const Color(0xFF161A22),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: dari Colors.white.withOpacity(0.06) → border palette
        borderSide: const BorderSide(
          color: Color(0xFF252B38),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: dari Colors.lightBlueAccent → primary blue
        borderSide: const BorderSide(
          color: Color(0xFF2979FF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // ✅ CHANGED: dari Colors.redAccent → merah lebih dalam
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