import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/repositories/tips/tips_repository.dart';
import 'package:flextime_mobile/logic/bloc/tips/tips_bloc.dart';
import 'package:flextime_mobile/logic/bloc/tips/tips_event.dart';
import 'package:flextime_mobile/logic/bloc/tips/tips_state.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_bloc.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_state.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_bloc.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_state.dart';
import 'package:flextime_mobile/utils/time_util.dart';

class BerandaPage extends StatelessWidget {
  final String namaPengguna;

  const BerandaPage({
    super.key,
    required this.namaPengguna,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TipsBloc(
        tipsRepository: TipsRepository(apiProvider: ApiProvider()),
      )..add(FetchTipsRequested()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildDashboardStats(context),
            const SizedBox(height: 16),
            Builder(builder: (context) => _buildTipsCard(context)),
            const SizedBox(height: 160), // Padded extra for the large floating button
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            BlocBuilder<PenggunaBloc, PenggunaState>(
              builder: (context, state) {
                String name = namaPengguna;
                if (state is PenggunaProfilLoaded) {
                  name = state.user.namaLengkap;
                } else if (state is PenggunaUpdateSuccess) {
                  name = state.user.namaLengkap;
                }
                return Text(
                  'Halo, $name',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00ACC1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00ACC1).withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStats(BuildContext context) {
    return BlocBuilder<PenggunaBloc, PenggunaState>(
      builder: (context, penggunaState) {
        List<String> jadwal = [];

        if (penggunaState is PenggunaProfilLoaded) {
          jadwal = penggunaState.user.jadwalMicrobreak;
        } else if (penggunaState is PenggunaUpdateSuccess) {
          jadwal = penggunaState.user.jadwalMicrobreak;
        }

        return BlocBuilder<RiwayatBloc, RiwayatState>(
          builder: (context, riwayatState) {
            List<dynamic> riwayatsToday = [];
            if (riwayatState is RiwayatLoaded) {
              final today = DateTime.now().toIso8601String().split('T')[0];
              riwayatsToday = riwayatState.riwayatList.where((r) => r.tanggal == today || (r.dibuatPada != null && r.dibuatPada!.startsWith(today))).toList();
            }

            String nextSessionTime = TimeUtil.getNextSessionTime(jadwal, riwayatsToday);

            bool isPagiDone = false;
            bool isSiangDone = false;
            bool isSoreDone = false;
            int missedCount = 0;

            if (riwayatState is RiwayatLoaded) {
              final today = DateTime.now().toIso8601String().split('T')[0];
              final riwayatsToday = riwayatState.riwayatList.where((r) => r.tanggal == today || (r.dibuatPada != null && r.dibuatPada!.startsWith(today))).toList();

              isPagiDone = riwayatsToday.any((r) => (r.sesi.toLowerCase() == 'pagi' || r.sesi.toLowerCase() == 'sesi 1') && r.statusKepatuhan.toLowerCase() == 'melakukan');
              isSiangDone = riwayatsToday.any((r) => (r.sesi.toLowerCase() == 'siang' || r.sesi.toLowerCase() == 'sesi 2') && r.statusKepatuhan.toLowerCase() == 'melakukan');
              isSoreDone = riwayatsToday.any((r) => (r.sesi.toLowerCase() == 'sore' || r.sesi.toLowerCase() == 'sesi 3') && r.statusKepatuhan.toLowerCase() == 'melakukan');

              // missedCount calculation (overall)
              missedCount = riwayatState.riwayatList.where((r) => r.statusKepatuhan.toLowerCase() == 'tidak').length;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPencapaianCard(isPagiDone, isSiangDone, isSoreDone, jadwal),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('SESI SELANJUTNYA', nextSessionTime, Icons.access_time_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfoCard('MELEWATKAN SESI', missedCount.toString(), Icons.local_fire_department_rounded, subtext: 'KALI')),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }



  Widget _buildPencapaianCard(bool isPagiDone, bool isSiangDone, bool isSoreDone, List<String> jadwal) {
    String getFormattedTime(int index) {
      if (jadwal.length > index) {
        String t = jadwal[index];
        return t.length > 5 ? t.substring(0, 5) : t;
      }
      return '--:--';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22), // Warna card gelap
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFF00ACC1),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Task Harian',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildProgressSegment(isPagiDone, 'Sesi 1', getFormattedTime(0)),
              const SizedBox(width: 12),
              _buildProgressSegment(isSiangDone, 'Sesi 2', getFormattedTime(1)),
              const SizedBox(width: 12),
              _buildProgressSegment(isSoreDone, 'Sesi 3', getFormattedTime(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSegment(bool isActive, String label, String timeLabel) {
    return Expanded(
      child: Column(
        children: [
          Text(
            timeLabel,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00ACC1) : const Color(0xFF2C2F36),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, {String? subtext}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: title.contains('MELEWATKAN') ? Colors.orangeAccent : const Color(0xFF00ACC1),
              size: 24,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtext,
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return BlocBuilder<TipsBloc, TipsState>(
      builder: (context, state) {
        String judul = 'Tips Postur';
        String konten = 'Pastikan bahu Anda rileks saat mengetik. Jaga monitor sejajar dengan pandangan mata.';
        bool isLoading = state is TipsLoading;

        if (state is TipsLoaded && state.tips.isNotEmpty) {
          // Mengacak daftar tips agar yang muncul berganti-ganti setiap kali dimuat
          final tip = (state.tips.toList()..shuffle()).first;
          judul = tip.judul;
          konten = tip.kontenPesan;
        } else if (state is TipsError) {
          konten = 'Gagal memuat tips: ${state.message}';
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E22),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF00ACC1),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        judul,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        konten,
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
