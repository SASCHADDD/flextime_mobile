import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';

class ProfilPage extends StatelessWidget {
  final String namaPengguna;

  const ProfilPage({
    super.key,
    required this.namaPengguna,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00ACC1).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF00ACC1),
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            namaPengguna,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          TextButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            label: Text(
              'Keluar',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
