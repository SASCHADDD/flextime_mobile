import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flextime_mobile/ui/pages/auth/login_page.dart';
import '../dashboard/main_layout.dart';
import '../admin/admin_main_layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    // Tunggu 3 detik, lalu cek otentikasi
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final role = state.user?.peran ?? 'user';
          final nama = state.user?.namaLengkap ?? 'Pengguna';
          
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminMainLayout(namaPengguna: nama),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainLayout(namaPengguna: nama),
              ),
            );
          }
        } else if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121418),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo FlexTime (dengan efek glow cyan)
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.layers_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Judul Aplikasi
                Text(
                  'FlexTime',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'STAY ACTIVE, STAY PRODUCTIVE',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00ACC1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
