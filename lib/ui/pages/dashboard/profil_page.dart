import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../logic/bloc/auth/auth_bloc.dart';
import '../../../../logic/bloc/auth/auth_event.dart';
import '../../../../logic/bloc/pengguna/pengguna_bloc.dart';
import '../../../../logic/bloc/pengguna/pengguna_event.dart';
import '../../../../logic/bloc/pengguna/pengguna_state.dart';
import '../../widgets/custom_time_picker.dart';

class ProfilPage extends StatelessWidget {
  final String namaPengguna;

  const ProfilPage({
    super.key,
    required this.namaPengguna,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfilView(initialName: namaPengguna);
  }
}

class _ProfilView extends StatefulWidget {
  final String initialName;

  const _ProfilView({required this.initialName});

  @override
  State<_ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<_ProfilView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  String _jamMasuk = "08:00:00";
  String _jamKeluar = "17:00:00";
  String _jamMulaiIstirahat = "12:00:00";
  String _jamSelesaiIstirahat = "13:00:00";

  bool _isInit = false;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _initDataFromUser(user) {
    if (!_isInit) {
      _namaController.text = user.namaLengkap;
      _jamMasuk = user.jamMasukKerja;
      _jamKeluar = user.jamKeluarKerja;
      _jamMulaiIstirahat = user.jamMulaiIstirahat;
      _jamSelesaiIstirahat = user.jamSelesaiIstirahat;
      _isInit = true;
    }
  }

  Future<void> _selectTime(BuildContext context, String initialTime, Function(String) onTimeSelected) async {
    await CustomTimePicker.selectTime(context, initialTime, onTimeSelected);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PenggunaBloc, PenggunaState>(
      listener: (context, state) {
        if (state is PenggunaUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PenggunaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PenggunaLoading && !_isInit) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00ACC1)),
          );
        }

        if (state is PenggunaProfilLoaded || state is PenggunaUpdateSuccess) {
          final user = (state is PenggunaProfilLoaded) 
              ? state.user 
              : (state as PenggunaUpdateSuccess).user;
          _initDataFromUser(user);
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Header
                  Center(
                    child: Container(
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Penyeimbang di kiri (SizedBox 8 + Icon 20 = 28)
                      const SizedBox(width: 28),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _namaController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nama Lengkap',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit_rounded,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),



                  // Pengaturan Jadwal
                  Text(
                    'JADWAL KERJA & ISTIRAHAT',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerField(
                    context: context,
                    label: 'Jam Masuk Kerja',
                    time: _jamMasuk,
                    icon: Icons.login_rounded,
                    onSelected: (val) => setState(() => _jamMasuk = val),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerField(
                    context: context,
                    label: 'Jam Keluar Kerja',
                    time: _jamKeluar,
                    icon: Icons.logout_rounded,
                    onSelected: (val) => setState(() => _jamKeluar = val),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerField(
                    context: context,
                    label: 'Mulai Istirahat',
                    time: _jamMulaiIstirahat,
                    icon: Icons.coffee_rounded,
                    onSelected: (val) => setState(() => _jamMulaiIstirahat = val),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerField(
                    context: context,
                    label: 'Selesai Istirahat',
                    time: _jamSelesaiIstirahat,
                    icon: Icons.work_history_rounded,
                    onSelected: (val) => setState(() => _jamSelesaiIstirahat = val),
                  ),

                  const SizedBox(height: 48),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: state is PenggunaLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<PenggunaBloc>().add(
                                UpdateProfilRequested(
                                  namaLengkap: _namaController.text,
                                  jamMasukKerja: _jamMasuk,
                                  jamKeluarKerja: _jamKeluar,
                                  jamMulaiIstirahat: _jamMulaiIstirahat,
                                  jamSelesaiIstirahat: _jamSelesaiIstirahat,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: state is PenggunaLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Keluar
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
                      'Keluar dari Akun',
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // spacing bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimePickerField({
    required BuildContext context,
    required String label,
    required String time,
    required IconData icon,
    required Function(String) onSelected,
  }) {
    // Potong detik (HH:mm:ss -> HH:mm) untuk tampilan UI
    final displayTime = time.length >= 5 ? time.substring(0, 5) : time;

    return InkWell(
      onTap: () => _selectTime(context, time, onSelected),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              displayTime,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }
}
