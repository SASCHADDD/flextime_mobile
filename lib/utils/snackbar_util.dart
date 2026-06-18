import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarUtil {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.check_circle_rounded,
      iconColor: const Color(0xFF00ACC1), // Cyan / Greenish
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.cancel_rounded,
      iconColor: Colors.redAccent,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.warning_rounded,
      iconColor: Colors.orangeAccent,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.info_outline_rounded,
      iconColor: Colors.blueAccent,
    );
  }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required IconData iconData,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1E22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: iconColor.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
