import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/gerakan/gerakan_model.dart';

class GerakanDetailModal extends StatelessWidget {
  final GerakanModel gerakan;
  final String? imageUrl;

  const GerakanDetailModal({
    super.key,
    required this.gerakan,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Gambar Gerakan (Premium Card Style)
          if (imageUrl != null)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF121418),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.contain,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),
          if (imageUrl != null) const SizedBox(height: 32),

          // Judul
          Text(
            gerakan.namaGerakan,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Durasi Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF00ACC1), size: 18),
                const SizedBox(width: 6),
                Text(
                  '${gerakan.durasiDetik} detik',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00ACC1),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Garis pemisah
          Divider(color: Colors.white.withValues(alpha: 0.05), thickness: 1),
          const SizedBox(height: 24),

          // Deskripsi
          Text(
            'Panduan Gerakan',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gerakan.deskripsi,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 40),
          
          // Tombol Tutup
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1C1E22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Text(
                'Tutup',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
