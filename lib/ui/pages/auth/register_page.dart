import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_bloc.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flextime_mobile/ui/widgets/custom_error_dialog.dart';
import 'package:flextime_mobile/utils/snackbar_util.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _workStartController = TextEditingController();
  final TextEditingController _workEndController = TextEditingController();
  final TextEditingController _breakStartController = TextEditingController();
  final TextEditingController _breakEndController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _workStartController.dispose();
    _workEndController.dispose();
    _breakStartController.dispose();
    _breakEndController.dispose();
    super.dispose();
  }

  void _showErrorPopup(String message) {
    CustomErrorDialog.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan BlocProvider agar BlocConsumer di bawah bisa menemukan AuthBloc
    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: AuthRepository(
          apiProvider: ApiProvider(),
          storageProvider: StorageProvider(),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121418),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo and Title FlexTime
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACC1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.layers_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Flextime',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title Buat akun
              Text(
                'Buat akun',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Atur profil Anda untuk mulai melacak kesehatan\ndan produktivitas.',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Forms
              _buildTextField(
                hintText: 'Nama Lengkap',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                hintText: 'Email',
                controller: _emailController,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  '* Gunakan format email yang valid (contoh: nama@mail.com)',
                  style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                hintText: 'Kata Sandi',
                controller: _passwordController,
                isPassword: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  '* Kata sandi minimal 6 karakter',
                  style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),

              Text(
                'Jadwal Kerja',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Grid for Schedules
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      label: 'Waktu Mulai Kerja',
                      controller: _workStartController,
                      isTime: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledField(
                      label: 'Waktu Selesai Kerja',
                      controller: _workEndController,
                      isTime: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      label: 'Waktu Mulai Istirahat',
                      controller: _breakStartController,
                      isTime: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledField(
                      label: 'Waktu Selesai Istirahat',
                      controller: _breakEndController,
                      isTime: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Register Button — BlocConsumer bisa menemukan AuthBloc karena
              // BlocProvider ada di atas Scaffold dalam widget tree ini
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthRegisterSuccess) {
                    SnackBarUtil.showSuccess(context, 'Registrasi berhasil! Silakan login.');
                    Navigator.of(context).pop();
                  } else if (state is AuthError) {
                    _showErrorPopup(state.message);
                  }
                },
                builder: (context, state) {
                  return Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00ACC1).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              final namaLengkap = _nameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              final wStart = _workStartController.text.trim();
                              final wEnd = _workEndController.text.trim();
                              final bStart = _breakStartController.text.trim();
                              final bEnd = _breakEndController.text.trim();

                              if (namaLengkap.isEmpty || email.isEmpty || password.isEmpty || 
                                  wStart.isEmpty || wEnd.isEmpty || bStart.isEmpty || bEnd.isEmpty) {
                                _showErrorPopup('Harap isi semua kolom dengan lengkap.');
                                return;
                              }

                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(email)) {
                                _showErrorPopup('Format email tidak valid.\nContoh: pengguna@mail.com');
                                return;
                              }

                              if (password.length < 6) {
                                _showErrorPopup('Kata sandi terlalu pendek. Minimal harus 6 karakter.');
                                return;
                              }

                              final timeRegex = RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$');
                              if (!timeRegex.hasMatch(wStart) || !timeRegex.hasMatch(wEnd) || 
                                  !timeRegex.hasMatch(bStart) || !timeRegex.hasMatch(bEnd)) {
                                _showErrorPopup('Format waktu tidak valid.\nGunakan format 24 Jam (Contoh: 08:30 atau 17:00) dengan maksimal 23:59.');
                                return;
                              }

                              context.read<AuthBloc>().add(
                                    AuthRegisterRequested(
                                      namaLengkap,
                                      email,
                                      password,
                                      wStart,
                                      wEnd,
                                      bStart,
                                      bEnd,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'Daftar',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    bool isTime = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isTime ? TextInputType.number : TextInputType.text,
            inputFormatters: isTime ? [TimeTextInputFormatter()] : null,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: isTime ? '00:00' : null,
              hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Hanya ambil angka
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Batasi maksimal 4 digit angka (HH:MM)
    if (newText.length > 4) {
      newText = newText.substring(0, 4);
    }

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) {
        formattedText += ':';
      }
      formattedText += newText[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
