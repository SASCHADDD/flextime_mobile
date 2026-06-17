import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flextime_mobile/logic/bloc/notifikasi/notifikasi_bloc.dart';
import 'package:flextime_mobile/logic/bloc/notifikasi/notifikasi_state.dart';
import 'package:flextime_mobile/logic/bloc/notifikasi/notifikasi_event.dart';
import 'package:flextime_mobile/data/models/notifikasi/notifikasi_model.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: _buildHeader(context),
          ),
          Expanded(
            child: BlocBuilder<NotifikasiBloc, NotifikasiState>(
              builder: (context, state) {
                if (state is NotifikasiLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00ACC1)));
                } else if (state is NotifikasiError) {
                  return Center(
                    child: Text(
                      'Gagal memuat notifikasi: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is NotifikasiLoaded) {
                  final list = state.notifikasi;
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada notifikasi',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF00ACC1),
                    backgroundColor: const Color(0xFF1C1E22),
                    onRefresh: () async {
                      context.read<NotifikasiBloc>().add(FetchNotifikasiRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 100),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final notif = list[index];
                        return _buildNotificationCard(
                          context,
                          notif: notif,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E22),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.done_all_rounded,
              color: Colors.white70,
              size: 20,
            ),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              context.read<NotifikasiBloc>().add(MarkAllReadRequested());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, {required NotifikasiModel notif}) {
    IconData icon;
    Color iconColor;

    switch (notif.tipe) {
      case 'success':
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF00ACC1);
        break;
      case 'warning':
        icon = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFFFB300);
        break;
      case 'error':
        icon = Icons.cancel_rounded;
        iconColor = Colors.redAccent;
        break;
      default:
        icon = Icons.info_rounded;
        iconColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          context.read<NotifikasiBloc>().add(MarkReadRequested(notif.id));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: !notif.isRead ? const Color(0xFF1C1E22).withValues(alpha: 0.8) : const Color(0xFF16181A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: !notif.isRead
                ? iconColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.02),
            width: 1,
          ),
          boxShadow: !notif.isRead
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Notifikasi
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Konten Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: !notif.isRead ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(notif.createdAt),
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif.pesan,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Titik merah penanda belum dibaca (Unread Indicator)
            if (!notif.isRead) ...[
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00ACC1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}j lalu';
      } else {
        return '${diff.inDays}h lalu';
      }
    } catch (e) {
      return '';
    }
  }
}
