import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_bloc.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_event.dart';
import 'package:flextime_mobile/utils/time_util.dart';
import 'package:flextime_mobile/ui/widgets/daily_riwayat_card.dart';
import 'package:flextime_mobile/ui/widgets/load_more_button.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedFilterIndex = 0; // 0: Harian, 1: Mingguan, 2: Bulanan
  int _paginationLimit = 5; // Batas paginasi awal (menampilkan 5 hari terakhir)

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 48),
            Builder(builder: (context) => _buildRiwayatHeader(context)),
            const SizedBox(height: 24),
            
            Builder(builder: (context) => _buildRiwayatContent(context)),
            
            const SizedBox(height: 160), // spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatContent(BuildContext context) {
    return BlocBuilder<RiwayatBloc, RiwayatState>(
      builder: (context, state) {
        if (state is RiwayatLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00ACC1)),
              ),
            ),
          );
        } else if (state is RiwayatError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Gagal memuat riwayat:\n${state.message}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.red[300]),
              ),
            ),
          );
        } else if (state is RiwayatLoaded) {
          final riwayatList = state.riwayatList;
          if (riwayatList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Belum ada riwayat sesi.',
                  style: GoogleFonts.inter(color: Colors.grey[500]),
                ),
              ),
            );
          }

          // Group by date
          final Map<String, List<dynamic>> groupedData = {};
          
          for (var riwayat in riwayatList) {
            final dateStr = riwayat.dibuatPada ?? '';
            final label = _formatDateLabel(dateStr);
            
            if (!groupedData.containsKey(label)) {
              groupedData[label] = [];
            }
            groupedData[label]!.add(riwayat);
          }

          final List<Widget> finalWidgets = [];
          
          // Pagination: Ambil hanya sejumlah limit dari entry hari yang ada
          final entries = groupedData.entries.toList();
          final paginatedEntries = entries.take(_paginationLimit).toList();

          for (var entry in paginatedEntries) {
            final label = entry.key;
            final sessions = entry.value;

            finalWidgets.add(_buildDateLabel(label));
            finalWidgets.add(const SizedBox(height: 16));
            finalWidgets.add(DailyRiwayatCard(sessions: sessions));
            finalWidgets.add(const SizedBox(height: 24));
          }

          // Tombol Load More
          if (entries.length > _paginationLimit) {
             finalWidgets.add(
               LoadMoreButton(
                 onLoadMore: () async {
                   // Beri sedikit jeda agar terasa natural/halus
                   await Future.delayed(const Duration(milliseconds: 600));
                   setState(() {
                     _paginationLimit += 5; // Tampilkan 5 hari lagi
                   });
                 },
               ),
             );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: finalWidgets,
          );
        }

        return const SizedBox();
      },
    );
  }

  String _formatDateLabel(String dateString) {
    if (dateString.isEmpty) return 'TANGGAL TIDAK DIKETAHUI';
    
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime targetDate = DateTime(date.year, date.month, date.day);

      if (targetDate == today) {
        return 'HARI INI';
      } else if (targetDate == yesterday) {
        return 'KEMARIN';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      return dateString.substring(0, 10);
    }
  }

  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '--:--';
    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Laporan',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Riwayat Sesi',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildFilterOption(context, 0, 'harian', 'Harian'),
              _buildFilterOption(context, 1, 'mingguan', 'Mingguan'),
              _buildFilterOption(context, 2, 'bulanan', 'Bulanan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(BuildContext context, int index, String filterValue, String label) {
    final isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          setState(() {
            _selectedFilterIndex = index;
            _paginationLimit = 5; // Reset limit saat pindah tab
          });
          context.read<RiwayatBloc>().add(FetchRiwayatRequested(filter: filterValue));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00838F).withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? const Color(0xFF00ACC1) : Colors.grey[600],
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDateLabel(String date) {
    return Text(
      date,
      style: GoogleFonts.inter(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String time,
    required bool isCompleted,
    String? missedLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ikon status
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF00ACC1).withValues(alpha: 0.05)
                  : Colors.grey[900],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF00ACC1).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: isCompleted ? const Color(0xFF00ACC1) : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          
          // Teks detail sesi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isCompleted ? Colors.white : Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Label dilewatkan (jika ada)
          if (!isCompleted && missedLabel != null)
            Text(
              missedLabel,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

}
