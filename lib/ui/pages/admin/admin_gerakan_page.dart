import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/providers/api_provider.dart';
import '../../../../logic/bloc/gerakan/gerakan_bloc.dart';
import '../../../../logic/bloc/gerakan/gerakan_event.dart';
import '../../../../logic/bloc/gerakan/gerakan_state.dart';
import 'admin_form_gerakan_page.dart';

class AdminGerakanPage extends StatelessWidget {
  const AdminGerakanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AdminGerakanView();
  }
}

class _AdminGerakanView extends StatelessWidget {
  const _AdminGerakanView();

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C20),
          title: Text(
            'Hapus Gerakan',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus $name? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<GerakanBloc>().add(DeleteGerakan(id));
              },
              child: Text('Hapus', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<GerakanBloc, GerakanState>(
        listener: (context, state) {
          if (state is GerakanOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is GerakanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is GerakanLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00ACC1)),
            );
          }

          if (state is GerakanLoaded) {
            final gerakans = state.gerakanList;
            if (gerakans.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada gerakan.\nTekan + untuk menambahkan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: gerakans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final gerakan = gerakans[index];
                final imageUrl = gerakan.gambar != null && gerakan.gambar!.isNotEmpty
                    ? '${ApiProvider.baseUrl.replaceAll('/api', '')}${gerakan.gambar}'
                    : null;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF1A1C20),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (imageUrl != null)
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.contain, // Ubah dari cover ke contain agar tidak terpotong
                                      ),
                                    ),
                                  ),
                                if (imageUrl != null) const SizedBox(height: 24),
                                Text(
                                  gerakan.namaGerakan,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Color(0xFF00ACC1), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${gerakan.durasiDetik} detik',
                                      style: GoogleFonts.inter(color: const Color(0xFF00ACC1), fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Deskripsi',
                                  style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  gerakan.deskripsi,
                                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 15, height: 1.5),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null
                          ? const Icon(Icons.image_not_supported_rounded, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      gerakan.namaGerakan,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${gerakan.durasiDetik} detik',
                              style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gerakan.deskripsi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Color(0xFF00ACC1)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<GerakanBloc>(),
                                  child: AdminFormGerakanPage(gerakan: gerakan),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () => _showDeleteDialog(context, gerakan.id, gerakan.namaGerakan),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
