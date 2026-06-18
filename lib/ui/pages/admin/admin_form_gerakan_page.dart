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
import '../../widgets/custom_error_dialog.dart';
import '../../widgets/custom_success_dialog.dart';

class AdminFormGerakanPage extends StatefulWidget {
  final GerakanModel? gerakan; // Null jika nambah baru, ada isi jika edit

  const AdminFormGerakanPage({super.key, this.gerakan});

  @override
  State<AdminFormGerakanPage> createState() => _AdminFormGerakanPageState();
}

class _AdminFormGerakanPageState extends State<AdminFormGerakanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final List<TextEditingController> _deskripsiControllers = [];
  final _durasiController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.gerakan != null) {
      _namaController.text = widget.gerakan!.namaGerakan;
      _durasiController.text = widget.gerakan!.durasiDetik.toString();
      
      if (widget.gerakan!.deskripsi.isNotEmpty) {
        final lines = widget.gerakan!.deskripsi.split('\n');
        for (var line in lines) {
          _deskripsiControllers.add(TextEditingController(text: line));
        }
      } else {
        _deskripsiControllers.add(TextEditingController());
      }
    } else {
      _deskripsiControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    for (var controller in _deskripsiControllers) {
      controller.dispose();
    }
    _durasiController.dispose();
    super.dispose();
  }

  void _addDeskripsiField() {
    setState(() {
      _deskripsiControllers.add(TextEditingController());
    });
  }

  void _removeDeskripsiField(int index) {
    setState(() {
      _deskripsiControllers[index].dispose();
      _deskripsiControllers.removeAt(index);
    });
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
        CustomErrorDialog.show(context, 'Gambar wajib diisi untuk gerakan baru!');
        return;
      }

      final isEdit = widget.gerakan != null;
      final deskripsiJoined = _deskripsiControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .join('\n');

      if (isEdit) {
        context.read<GerakanBloc>().add(
              UpdateGerakan(
                id: widget.gerakan!.id,
                namaGerakan: _namaController.text.trim(),
                deskripsi: deskripsiJoined,
                durasiDetik: int.tryParse(_durasiController.text.trim()) ?? 60,
                gambar: _selectedImage, // Optional if edit
              ),
            );
      } else {
        context.read<GerakanBloc>().add(
              AddGerakan(
                namaGerakan: _namaController.text.trim(),
                deskripsi: deskripsiJoined,
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
        listener: (context, state) async {
          if (state is GerakanOperationSuccess) {
            await CustomSuccessDialog.show(context, state.message);
            if (context.mounted) {
              Navigator.pop(context); // Kembali ke list setelah dialog ditutup
            }
          } else if (state is GerakanError) {
            CustomErrorDialog.show(context, state.message);
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
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFF121418),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.contain,
                              )
                            : (isEdit && widget.gerakan!.gambar != null && widget.gerakan!.gambar!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      '${ApiProvider.baseUrl.replaceAll('/api', '')}${widget.gerakan!.gambar}',
                                    ),
                                    fit: BoxFit.contain,
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
                  
                  // --- Deskripsi Dinamis ---
                  Text(
                    'Langkah-langkah Gerakan',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_deskripsiControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _deskripsiControllers[index],
                              label: 'Langkah ${index + 1}',
                              hint: 'Deskripsikan langkah ke-${index + 1}...',
                              icon: Icons.format_list_numbered_rounded,
                              maxLines: 2,
                            ),
                          ),
                          if (_deskripsiControllers.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _removeDeskripsiField(index),
                                tooltip: 'Hapus langkah ini',
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  
                  // Tombol Tambah Langkah
                  OutlinedButton.icon(
                    onPressed: _addDeskripsiField,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text('Tambah Langkah', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00ACC1),
                      side: const BorderSide(color: Color(0xFF00ACC1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
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
