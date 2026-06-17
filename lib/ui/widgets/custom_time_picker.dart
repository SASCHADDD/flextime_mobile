import 'package:flutter/material.dart';

class CustomTimePicker {
  static Future<void> selectTime(
    BuildContext context,
    String initialTime,
    Function(String) onTimeSelected,
  ) async {
    final parts = initialTime.split(':');
    final initialTimeOfDay = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00ACC1),
              onPrimary: Colors.white,
              surface: Color(0xFF1C1E22),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onTimeSelected('$hour:$minute:00');
    }
  }
}
