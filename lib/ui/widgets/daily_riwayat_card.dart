import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyRiwayatCard extends StatelessWidget {
  final List<dynamic> sessions;

  const DailyRiwayatCard({
    super.key,
    required this.sessions,
  });

  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '--:--';
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final expectedSesiName = 'Sesi ${index + 1}';
          final expectedSesiLower = 'sesi ${index + 1}';
          final sessionNames = [expectedSesiLower, index == 0 ? 'pagi' : index == 1 ? 'siang' : 'sore'];
          
          // Cari apakah sesi ini ada di list
          final matches = sessions.where((s) => sessionNames.contains(s.sesi.toLowerCase()));
          final session = matches.isNotEmpty ? matches.first : null;

          bool isCompleted = false;
          bool isMissed = false;
          String time = '--:--';

          if (session != null) {
            isCompleted = session.statusKepatuhan == 'Ya' || session.statusKepatuhan.toLowerCase() == 'selesai' || session.statusKepatuhan.toLowerCase() == 'melakukan';
            isMissed = session.statusKepatuhan == 'Tidak' || session.statusKepatuhan.toLowerCase() == 'terlewat';
            time = _formatTime(session.dibuatPada ?? '');
          }

          return Expanded(
            child: _buildSessionMiniItem(
              title: expectedSesiName,
              time: time,
              isCompleted: isCompleted,
              isMissed: isMissed,
              hasData: session != null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSessionMiniItem({
    required String title,
    required String time,
    required bool isCompleted,
    required bool isMissed,
    required bool hasData,
  }) {
    Color iconColor = Colors.grey[700]!;
    IconData iconData = Icons.circle_outlined;
    
    if (isCompleted) {
      iconColor = const Color(0xFF00ACC1);
      iconData = Icons.check_circle_rounded;
    } else if (isMissed) {
      iconColor = Colors.redAccent;
      iconData = Icons.cancel_rounded;
    }

    return Column(
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 28,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            color: (isCompleted || isMissed) ? Colors.white : Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasData ? time : '--:--',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
