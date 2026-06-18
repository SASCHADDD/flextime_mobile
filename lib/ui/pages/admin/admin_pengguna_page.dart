import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../logic/bloc/pengguna/pengguna_bloc.dart';
import '../../../../logic/bloc/pengguna/pengguna_event.dart';
import '../../../../logic/bloc/pengguna/pengguna_state.dart';
import '../../widgets/load_more_button.dart';
import 'admin_laporan_aktivitas_page.dart';

class AdminPenggunaPage extends StatefulWidget {
  const AdminPenggunaPage({super.key});

  @override
  State<AdminPenggunaPage> createState() => _AdminPenggunaPageState();
}

class _AdminPenggunaPageState extends State<AdminPenggunaPage> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    context.read<PenggunaBloc>().add(FetchAllPenggunaRequested(query: query));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1A1C20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF00ACC1)),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: BlocBuilder<PenggunaBloc, PenggunaState>(
              builder: (context, state) {
                if (state is PenggunaLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00ACC1)));
                }

                if (state is PenggunaListLoaded) {
                  final users = state.users;
                  final total = state.total;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Text(
                          'Total $total Pengguna',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: users.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada pengguna ditemukan.',
                                  style: GoogleFonts.inter(color: Colors.grey[500]),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100), // padding bawah untuk menghindari FAB
                                itemCount: state.hasReachedMax ? users.length : users.length + 1,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index >= users.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: LoadMoreButton(
                                        onLoadMore: () async {
                                          context.read<PenggunaBloc>().add(LoadMorePenggunaRequested());
                                          // Tunggu sejenak agar UI memperbarui state (optional, tapi bagus utk UX)
                                          await Future.delayed(const Duration(milliseconds: 500));
                                        },
                                      ),
                                    );
                                  }
                                  
                                  final user = users[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1C20),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFF00ACC1).withValues(alpha: 0.2),
                                        child: Text(
                                          user.namaLengkap.isNotEmpty ? user.namaLengkap[0].toUpperCase() : '?',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF00ACC1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        user.namaLengkap,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AdminLaporanAktivitasPage(user: user),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                if (state is PenggunaError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.inter(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
