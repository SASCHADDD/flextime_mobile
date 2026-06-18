import 'package:flextime_mobile/ui/widgets/daily_riwayat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/auth/user_model.dart';
import '../../../../data/models/riwayat/riwayat_model.dart';
import '../../../../logic/bloc/riwayat/riwayat_bloc.dart';
import '../../../../logic/bloc/riwayat/riwayat_event.dart';
import '../../../../logic/bloc/riwayat/riwayat_state.dart';
import '../../../../data/repositories/riwayat/riwayat_repository.dart';
import '../../../../data/providers/api_provider.dart';

class AdminLaporanAktivitasPage extends StatelessWidget {
  final UserModel user;

  const AdminLaporanAktivitasPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RiwayatBloc(
        riwayatRepository: RiwayatRepository(apiProvider: ApiProvider()),
      )..add(FetchRiwayatAdminRequested(int.tryParse(user.id) ?? 0)),
      child: Scaffold(
        backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan Aktivitas',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Profile
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF00ACC1).withValues(alpha: 0.2),
              child: Text(
                user.namaLengkap.isNotEmpty ? user.namaLengkap[0].toUpperCase() : '?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00ACC1),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.namaLengkap,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 32),

            // Laporan Aktivitas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Sesi harian',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                BlocBuilder<RiwayatBloc, RiwayatState>(
                  builder: (context, state) {
                    int totalDays = 0;
                    if (state is RiwayatLoaded) {
                      final dates = state.riwayatList.map((e) => e.tanggal).toSet();
                      totalDays = dates.length;
                    }
                    return Text(
                      '$totalDays Hari Tersimpan',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic cards
            BlocBuilder<RiwayatBloc, RiwayatState>(
              builder: (context, state) {
                if (state is RiwayatLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(color: Color(0xFF00ACC1)),
                  );
                } else if (state is RiwayatError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      state.message,
                      style: GoogleFonts.inter(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (state is RiwayatLoaded) {
                  if (state.riwayatList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        'Belum ada riwayat aktivitas.',
                        style: GoogleFonts.inter(color: Colors.grey[500]),
                      ),
                    );
                  }

                  // Group by date
                  final groupedRiwayat = <String, List<RiwayatModel>>{};
                  for (var riwayat in state.riwayatList) {
                    final tgl = riwayat.tanggal ?? 'Unknown';
                    if (!groupedRiwayat.containsKey(tgl)) {
                      groupedRiwayat[tgl] = [];
                    }
                    groupedRiwayat[tgl]!.add(riwayat);
                  }

                  return Column(
                    children: groupedRiwayat.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTanggal(entry.key),
                              style: GoogleFonts.inter(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DailyRiwayatCard(sessions: entry.value),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ), // close Scaffold
    ); // close BlocProvider
  }

  String _formatTanggal(String tanggalStr) {
    if (tanggalStr == 'Unknown') return tanggalStr;
    final date = DateTime.tryParse(tanggalStr);
    if (date == null) return tanggalStr;
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari Ini';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Kemarin';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    }
  }
}
