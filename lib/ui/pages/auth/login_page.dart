import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import '../dashboard/main_layout.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: AuthRepository(
          apiProvider: ApiProvider(),
          storageProvider: StorageProvider(),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(
          0xFF121418,
        ), // Warna background gelap yang sleek
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo FlexTime (dengan efek glow cyan)
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1), // Warna cyan
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 0), // Glow merata di sekeliling
                      ),
                    ],
                  ),
                  child: const Center(
                    // Anda bisa mengganti ini dengan Image.asset atau SvgPicture
                    // jika menggunakan aset dari desainer.
                    child: Icon(
                      Icons.layers_rounded, // Ikon placeholder yang mirip
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Judul Aplikasi
                Text(
                  'FlexTime',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'PORTAL AUTENTIKASI',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00ACC1),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing:
                        2.0, // Memberikan jarak antar huruf yang elegan
                  ),
                ),
                const SizedBox(height: 48),
                // Card / Container Form Login
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1A1C20,
                    ), // Warna card sedikit lebih terang dari bg
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.03,
                      ), // Border tipis untuk detail
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Input Email / Username
                      _buildInputField(
                        label: 'Email',
                        hintText: 'Gunakan \'admin\' atau nama lain...',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 24),
                      // Input Password
                      _buildInputField(
                        label: 'Kata Sandi',
                        hintText: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 36),
                      // Tombol Masuk
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthAuthenticated) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainLayout(
                                  namaPengguna:
                                      state.user?.namaLengkap ?? 'Pengguna',
                                ),
                              ),
                            );
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00B4D8), // Gradient cyan terang
                                  Color(0xFF00838F), // Gradient cyan gelap
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00ACC1,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      final email = _emailController.text
                                          .trim();
                                      final password = _passwordController.text
                                          .trim();

                                      if (email.isNotEmpty &&
                                          password.isNotEmpty) {
                                        context.read<AuthBloc>().add(
                                          AuthLoginRequested(email, password),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Harap isi email/username dan kata sandi.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Transparan agar gradient terlihat
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: GoogleFonts.inter(
                                        color: const Color(
                                          0xFF121418,
                                        ), // Warna teks kontras (gelap)
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum memiliki akun? ',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar di sini',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00ACC1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey[500],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(
              0xFF121418,
            ), // Warna input field lebih gelap seperti di desain
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04), // Detail garis tipis
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border:
                  InputBorder.none, // Menghilangkan border default TextField
            ),
          ),
        ),
      ],
    );
  }
}
