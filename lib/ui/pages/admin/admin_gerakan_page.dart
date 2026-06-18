import 'package:flextime_mobile/logic/bloc/gerakan/gerakan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/providers/api_provider.dart';
import '../../../../logic/bloc/gerakan/gerakan_bloc.dart';
import '../../../../logic/bloc/gerakan/gerakan_event.dart';
import '../../widgets/admin_gerakan_card.dart';
import '../../widgets/gerakan_detail_modal.dart';
import '../../widgets/custom_error_dialog.dart';
import '../../widgets/custom_success_dialog.dart';
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
            if (ModalRoute.of(context)?.isCurrent == true) {
              CustomSuccessDialog.show(context, state.message);
            }
          } else if (state is GerakanError) {
            if (ModalRoute.of(context)?.isCurrent == true) {
              CustomErrorDialog.show(context, state.message);
            }
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

                return AdminGerakanCard(
                  gerakan: gerakan,
                  imageUrl: imageUrl,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1A1C20),
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return GerakanDetailModal(
                          gerakan: gerakan,
                          imageUrl: imageUrl,
                        );
                      },
                    );
                  },
                  onEdit: () {
                    final gerakanBloc = context.read<GerakanBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: gerakanBloc,
                          child: AdminFormGerakanPage(gerakan: gerakan),
                        ),
                      ),
                    );
                  },
                  onDelete: () => _showDeleteDialog(context, gerakan.id, gerakan.namaGerakan),
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
