import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterButtonTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF121418).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Beranda', Icons.home_rounded),
              _buildNavItem(1, 'Laporan', Icons.bar_chart_rounded),
              const SizedBox(width: 64), // Space for center button
              _buildNavItem(3, 'Notifikasi', Icons.notifications_none_rounded),
              _buildNavItem(4, 'Profil', Icons.person_outline_rounded),
            ],
          ),
          // Center Floating Button
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: onCenterButtonTap,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACC1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00ACC1).withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'fk', // Teks pendekatan untuk logo FlexTime di screenshot
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FlexTime!',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00ACC1),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isActive = currentIndex == index;
    final color = isActive ? const Color(0xFF00ACC1) : Colors.grey[600]!;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Indicator bar
            if (isActive)
              Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACC1),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00ACC1).withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 9),
            
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
