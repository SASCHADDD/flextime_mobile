import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/data/repositories/gerakan/gerakan_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_bloc.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_event.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_bloc.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_event.dart';
import 'package:flextime_mobile/data/repositories/pengguna/pengguna_repository.dart';

import '../auth/login_page.dart';
import 'admin_gerakan_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_form_gerakan_page.dart';

class AdminMainLayout extends StatefulWidget {
  final String namaPengguna;

  const AdminMainLayout({
    super.key,
    required this.namaPengguna,
  });

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminGerakanPage(),
      const AdminPenggunaPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(
              apiProvider: ApiProvider(),
              storageProvider: StorageProvider(),
            ),
          ),
        ),
        BlocProvider<GerakanBloc>(
          create: (_) => GerakanBloc(
            gerakanRepository: GerakanRepository(
              apiProvider: ApiProvider(),
            ),
          )..add(FetchGerakanRequested()),
        ),
        BlocProvider<PenggunaBloc>(
          create: (_) => PenggunaBloc(
            penggunaRepository: PenggunaRepository(
              apiProvider: ApiProvider(),
            ),
          )..add(const FetchAllPenggunaRequested()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFF121418),
              appBar: AppBar(
                backgroundColor: const Color(0xFF1A1C20),
                leading: null,
                automaticallyImplyLeading: false,
                title: Text(
                  _currentIndex == 0 ? 'Admin Gerakan' : 'Kelola Pengguna',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF00ACC1).withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 20, color: Color(0xFF00ACC1)),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              body: _pages[_currentIndex],
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: _currentIndex == 0 ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00ACC1).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF00ACC1),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                  onPressed: () {
                    // Tambah Gerakan
                    final gerakanBloc = context.read<GerakanBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (navContext) => BlocProvider.value(
                          value: gerakanBloc,
                          child: const AdminFormGerakanPage(),
                        ),
                      ),
                    );
                  },
                ),
              ) : null,
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C20),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                ),
                child: BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  notchMargin: 8,
                  shape: const CircularNotchedRectangle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.fitness_center_rounded, 'Gerakan'),
                      const SizedBox(width: 48), // Spasi untuk FAB
                      _buildNavItem(1, Icons.group_rounded, 'Pengguna'),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF00ACC1) : Colors.grey[600];

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
