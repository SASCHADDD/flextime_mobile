import 'dart:math' as math;
import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_bloc.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_event.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_state.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_bloc.dart';
import 'package:flextime_mobile/logic/bloc/pengguna/pengguna_state.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_bloc.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_event.dart';
import 'package:flextime_mobile/utils/time_util.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_bloc.dart';
import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlexTimeScreen extends StatelessWidget {
  const FlexTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _tampilkanDialogBatal(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121418), // Dark mode background
        body: SafeArea(
          child: BlocConsumer<SesiLatihanBloc, SesiLatihanState>(
            listener: (context, state) {
              if (state is SesiSelesai) {
                _tampilkanModalSelesai(context);
              }
            },
            builder: (context, state) {
              if (state is SesiPersiapan) {
                return _buildLayarPersiapan(context, state.sisaWaktu, state.gerakanSelanjutnya.namaGerakan);
              } else if (state is SesiBerjalan) {
                return _buildMainLayout(context, state.sisaWaktu, state.gerakanSaatIni);
              } else if (state is SesiTransisi) {
                return _buildLayarPersiapan(context, state.sisaWaktu, "Selanjutnya:\n${state.gerakanSelanjutnya.namaGerakan}");
              } else if (state is SesiLatihanInitial) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
              }

              return const Center(child: Text("Sesi Dibatalkan", style: TextStyle(color: Colors.white)));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainLayout(BuildContext context, int sisaWaktu, GerakanModel gerakan) {
    String titleText = gerakan.namaGerakan;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Judul
        Text(
          titleText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 50),
        
        // Custom segmented timer
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: TimerPainter(),
              child: Center(
                child: Text(
                  "00:${sisaWaktu.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 50),

        // Expanded content (Image & Instructions)
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Gambar
                if (gerakan.gambar != null && gerakan.gambar!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      gerakan.gambar!.startsWith('http') 
                          ? gerakan.gambar! 
                          : 'http://127.0.0.1:3000/${gerakan.gambar!.replaceFirst(RegExp(r'^/+'), '')}',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    ),
                  )
                else
                  _buildImagePlaceholder(),

                const SizedBox(height: 30),

                // Instruksi List (Card abu-abu gelap)
                if (gerakan.deskripsi.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C20),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildInstructionBullets(gerakan.deskripsi),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Tombol Batal di Bawah
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TextButton(
            onPressed: () => _tampilkanDialogBatal(context),
            child: Text(
              "Batalkan Sesi",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayarPersiapan(BuildContext context, int sisaWaktu, String namaGerakan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Bersiaplah...",
            style: TextStyle(color: Colors.grey, fontSize: 24),
          ),
          const SizedBox(height: 40),
          Text(
            "$sisaWaktu",
            style: const TextStyle(
              color: Color(0xFF00E5FF), 
              fontSize: 120, 
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            namaGerakan,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 60),
          TextButton(
            onPressed: () => _tampilkanDialogBatal(context),
            child: Text(
              "Batalkan Sesi",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.fitness_center_rounded, color: Colors.grey, size: 64),
    );
  }

  List<Widget> _buildInstructionBullets(String deskripsi) {
    // Memecah berdasarkan newline terlebih dahulu, jika tidak ada, pecah berdasarkan titik.
    List<String> points = [];
    if (deskripsi.contains('\n')) {
      points = deskripsi.split('\n');
    } else if (deskripsi.contains('. ')) {
      points = deskripsi.split('. ');
    } else {
      points = [deskripsi];
    }

    // Bersihkan spasi kosong
    points = points.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return points.map((point) {
      // Pastikan ada titik di akhir jika terpotong oleh split('. ')
      String text = point;
      if (!text.endsWith('.') && points.length > 1 && !deskripsi.contains('\n')) {
        text += '.';
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cyan dot dengan glow
            Container(
              margin: const EdgeInsets.only(top: 6, right: 16),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // --- FUNGSI MODAL DARURAT ---
  void _tampilkanDialogBatal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Batalkan Latihan?", style: TextStyle(color: Colors.white)),
        content: const Text("Sesi latihan ini tidak akan disimpan ke riwayat.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Lanjutkan", style: TextStyle(color: Color(0xFF00E5FF))),
          ),
          TextButton(
            onPressed: () {
              context.read<SesiLatihanBloc>().add(BatalkanSesiRequested());
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI MODAL SELESAI ---
  void _tampilkanModalSelesai(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: const Color(0xFF1A1C20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 64),
            ),
            const SizedBox(height: 24),
            const Text("Sesi Selesai!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                final penggunaState = context.read<PenggunaBloc>().state;
                if (penggunaState is PenggunaProfilLoaded) {
                  final jadwal = penggunaState.user.jadwalMicrobreak;
                  final sesiStr = TimeUtil.getCurrentSessionName(jadwal);

                  context.read<RiwayatBloc>().add(
                    TambahRiwayatRequested({
                      'sesi': sesiStr,
                      'status_kepatuhan': 'Melakukan',
                    })
                  );
                }
                
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Simpan Latihan", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER UNTUK TIMER ---
class TimerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Faint background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Glowing active segments
    final activePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    const int numSegments = 4;
    const double gapSize = 0.35; // Lebar gap antar segmen
    final double sweepAngle = (2 * math.pi / numSegments) - gapSize;

    // Draw each segment
    for (int i = 0; i < numSegments; i++) {
      // Start offset so gaps are positioned evenly
      final startAngle = -math.pi / 2 + (i * (2 * math.pi / numSegments)) + (gapSize / 2);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}