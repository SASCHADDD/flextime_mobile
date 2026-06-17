import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/notifikasi/notifikasi_api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flextime_mobile/data/repositories/pengguna/pengguna_repository.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_bloc.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_event.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_state.dart';
import 'package:flextime_mobile/data/repositories/riwayat/riwayat_repository.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_bloc.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_event.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_state.dart';
import 'package:flextime_mobile/utils/time_util.dart';
import 'package:flextime_mobile/ui/pages/auth/login_page.dart';
import 'package:flextime_mobile/data/repositories/gerakan/gerakan_repository.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_bloc.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_event.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_state.dart';
import 'package:flextime_mobile/data/repositories/notifikasi/notifikasi_repository.dart';
import 'package:flextime_mobile/logic/bloc/notifikasi/notifikasi_bloc.dart';
import 'package:flextime_mobile/logic/bloc/notifikasi/notifikasi_event.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_bloc.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_event.dart';
import 'package:flextime_mobile/ui/pages/exercise/sesi_page.dart';

import '../../widgets/custom_bottom_nav_bar.dart';
import 'beranda_page.dart';
import 'laporan_page.dart';
import 'notifikasi_page.dart';
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
      const NotifikasiPage(),
      ProfilPage(namaPengguna: widget.namaPengguna),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(
              apiProvider: ApiProvider(),
              storageProvider: StorageProvider(),
            ),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => PenggunaBloc(
            penggunaRepository: PenggunaRepository(
              apiProvider: ApiProvider(),
            ),
          )..add(FetchProfilRequested()),
        ),
        BlocProvider(
          create: (_) => RiwayatBloc(
            riwayatRepository: RiwayatRepository(
              apiProvider: ApiProvider(),
            ),
          )..add(const FetchRiwayatRequested(filter: 'harian')),
        ),
        BlocProvider(
          lazy: false,
          create: (_) => GerakanBloc(
            gerakanRepository: GerakanRepository(
              apiProvider: ApiProvider(),
            ),
          )..add(FetchGerakanRequested()),
        ),
        BlocProvider(
          create: (_) => NotifikasiBloc(
            notifikasiRepository: NotifikasiRepository(
              apiProvider: NotifikasiApiProvider(
                storageProvider: StorageProvider(),
              ),
            ),
          )..add(FetchNotifikasiRequested()),
        ),
      ],
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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<PenggunaBloc, PenggunaState>(
                    builder: (context, penggunaState) {
                      return BlocBuilder<RiwayatBloc, RiwayatState>(
                        builder: (context, riwayatState) {
                          List<String> jadwal = [];
                          if (penggunaState is PenggunaProfilLoaded) {
                            jadwal = penggunaState.user.jadwalMicrobreak;
                          } else if (penggunaState is PenggunaUpdateSuccess) {
                            jadwal = penggunaState.user.jadwalMicrobreak;
                          }

                          bool isTimeValid = TimeUtil.isFlexTimeButtonActive(jadwal);
                          bool isAlreadyDone = false;

                          if (isTimeValid && riwayatState is RiwayatLoaded) {
                            String currentSesiName = TimeUtil.getCurrentSessionName(jadwal);
                            final today = DateTime.now().toIso8601String().split('T')[0];
                            final riwayatsToday = riwayatState.riwayatList.where(
                                (r) => r.tanggal == today || (r.dibuatPada != null && r.dibuatPada!.startsWith(today))
                            ).toList();
                            
                            isAlreadyDone = riwayatsToday.any((r) => 
                              r.sesi.toLowerCase() == currentSesiName.toLowerCase() && 
                              r.statusKepatuhan.toLowerCase() == 'melakukan'
                            );
                          }

                          bool isActive = isTimeValid && !isAlreadyDone;

                          return CustomBottomNavBar(
                            currentIndex: _currentIndex,
                            isFlexTimeButtonActive: isActive,
                            onTap: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            onCenterButtonTap: () {
                              final gerakanState = context.read<GerakanBloc>().state;
                              
                              if (gerakanState is GerakanLoaded && gerakanState.gerakanList.isNotEmpty) {
                                final authBloc = context.read<AuthBloc>();
                                final riwayatBloc = context.read<RiwayatBloc>();
                                final gerakanBloc = context.read<GerakanBloc>();
                                final penggunaBloc = context.read<PenggunaBloc>();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: authBloc),
                                        BlocProvider.value(value: riwayatBloc),
                                        BlocProvider.value(value: gerakanBloc),
                                        BlocProvider.value(value: penggunaBloc),
                                        BlocProvider(
                                          create: (_) => SesiLatihanBloc()..add(MulaiSesiRequested(gerakanState.gerakanList)),
                                        ),
                                      ],
                                      child: const FlexTimeScreen(),
                                    ),
                                  ),
                                );
                              } else if (gerakanState is GerakanLoading) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sedang memuat data gerakan...')),
                                );
                              } else if (gerakanState is GerakanError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal memuat gerakan: ${gerakanState.message}')),
                                );
                                context.read<GerakanBloc>().add(FetchGerakanRequested());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Belum ada gerakan tersedia untuk saat ini.')),
                                );
                              }
                            },
                          );
                        }
                      );
                    }
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
