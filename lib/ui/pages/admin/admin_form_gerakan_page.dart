import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/gerakan/gerakan_model.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../logic/bloc/gerakan/gerakan_bloc.dart';
import '../../../../logic/bloc/gerakan/gerakan_event.dart';
import '../../../../logic/bloc/gerakan/gerakan_state.dart';

class AdminFormGerakanPage extends StatefulWidget {
  final GerakanModel? gerakan; // Null jika nambah baru, ada isi jika edit

  const AdminFormGerakanPage({super.key, this.gerakan});

  @override
  State<AdminFormGerakanPage> createState() => _AdminFormGerakanPageState();
}

class _AdminFormGerakanPageState extends State<AdminFormGerakanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _durasiController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.gerakan != null) {
      _namaController.text = widget.gerakan!.namaGerakan;
      _deskripsiController.text = widget.gerakan!.deskripsi;
      _durasiController.text = widget.gerakan!.durasiDetik.toString();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.gerakan == null && _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar wajib diisi untuk gerakan baru!'), backgroundColor: Colors.red),
        );
        return;
      }

      final isEdit = widget.gerakan != null;

      if (isEdit) {
        context.read<GerakanBloc>().add(
              UpdateGerakan(
                id: widget.gerakan!.id,
                namaGerakan: _namaController.text.trim(),
                deskripsi: _deskripsiController.text.trim(),
                durasiDetik: int.tryParse(_durasiController.text.trim()) ?? 60,
                gambar: _selectedImage, // Optional if edit
              ),
            );
      } else {
        context.read<GerakanBloc>().add(
              AddGerakan(
                namaGerakan: _namaController.text.trim(),
                deskripsi: _deskripsiController.text.trim(),
                durasiDetik: int.tryParse(_durasiController.text.trim()) ?? 60,
                gambar: _selectedImage!, // Mandatory if new
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.gerakan != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C20),
        title: Text(
          isEdit ? 'Edit Gerakan' : 'Tambah Gerakan',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<GerakanBloc, GerakanState>(
        listener: (context, state) {
          if (state is GerakanOperationSuccess) {
            Navigator.pop(context); // Kembali ke list setelah sukses
          } else if (state is GerakanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Gambar Picker ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (isEdit && widget.gerakan!.gambar != null && widget.gerakan!.gambar!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      '${ApiProvider.baseUrl.replaceAll('/api', '')}${widget.gerakan!.gambar}',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedImage == null &&
                              (!isEdit || widget.gerakan!.gambar == null || widget.gerakan!.gambar!.isEmpty))
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, color: Colors.grey[600], size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Pilih Foto Gerakan',
                                  style: GoogleFonts.inter(color: Colors.grey[500], fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Input fields ---
                  _buildInputField(
                    controller: _namaController,
                    label: 'Nama Gerakan',
                    hint: 'Misal: Neck Stretch',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    controller: _deskripsiController,
                    label: 'Deskripsi',
                    hint: 'Misal: Miringkan kepala ke kanan dan ke kiri...',
                    icon: Icons.description_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    controller: _durasiController,
                    label: 'Durasi (detik)',
                    hint: 'Misal: 60',
                    icon: Icons.timer_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 48),

                  // --- Submit button ---
                  ElevatedButton(
                    onPressed: state is GerakanLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: state is GerakanLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Simpan Gerakan',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[700]),
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey[400], size: 20) : null,
        filled: true,
        fillColor: const Color(0xFF1C1E22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00ACC1)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
