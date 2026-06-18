import 'package:equatable/equatable.dart';

abstract class PenggunaEvent extends Equatable {
  const PenggunaEvent();

  @override
  List<Object?> get props => [];
}

// [USER/ADMIN] Fetch Profil Sendiri
class FetchProfilRequested extends PenggunaEvent {}

// [USER/ADMIN] Update Profil Sendiri
class UpdateProfilRequested extends PenggunaEvent {
  final String? namaLengkap;
  final String? jamMasukKerja;
  final String? jamKeluarKerja;
  final String? jamMulaiIstirahat;
  final String? jamSelesaiIstirahat;

  const UpdateProfilRequested({
    this.namaLengkap,
    this.jamMasukKerja,
    this.jamKeluarKerja,
    this.jamMulaiIstirahat,
    this.jamSelesaiIstirahat,
  });

  @override
  List<Object?> get props => [
        namaLengkap,
        jamMasukKerja,
        jamKeluarKerja,
        jamMulaiIstirahat,
        jamSelesaiIstirahat,
      ];
}

// [ADMIN] Fetch Semua Pengguna
class FetchAllPenggunaRequested extends PenggunaEvent {
  final String query;

  const FetchAllPenggunaRequested({this.query = ''});

  @override
  List<Object?> get props => [query];
}

class LoadMorePenggunaRequested extends PenggunaEvent {}