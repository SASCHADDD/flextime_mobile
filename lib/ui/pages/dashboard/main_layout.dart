import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flextime_mobile/ui/pages/auth/login_page.dart';

import '../../widgets/custom_bottom_nav_bar.dart';
import 'beranda_page.dart';
import 'laporan_page.dart';
import 'profil_page.dart';

class MainLayout extends StatefulWidget {
  final String namaPengguna;

  const MainLayout({
    super.key,
    required this.namaPengguna,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaPage(namaPengguna: widget.namaPengguna),
      const LaporanPage(),
      const SizedBox(), // Placeholder untuk tombol tengah
      _buildPlaceholderPage('Notifikasi'),
      ProfilPage(namaPengguna: widget.namaPengguna),
    ];
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
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
      child: Builder(builder: (context) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF121418),
            body: Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0x1F00ACC1),
                        Colors.transparent,
                      ],
                      center: Alignment.topCenter,
                      radius: 1.5,
                    ),
                  ),
                ),
                // Main Content
                IndexedStack(
                  index: _currentIndex == 2 ? 0 : _currentIndex, // Center button doesn't change active tab
                  children: _pages,
                ),
                // Custom Bottom Navigation
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomBottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    onCenterButtonTap: () {
                      // Tindakan tombol tengah (misalnya mulai sesi flex)
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
