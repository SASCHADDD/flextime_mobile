import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';

abstract class SesiLatihanState extends Equatable {
  const SesiLatihanState();
  
  @override
  List<Object?> get props => [];
}

class SesiLatihanInitial extends SesiLatihanState {}

// Fase 1: Layar hitung mundur sebelum gerakan dimulai (FR-EXR-01)
class SesiPersiapan extends SesiLatihanState {
  final int sisaWaktu;
  final GerakanModel gerakanSelanjutnya;

  const SesiPersiapan(this.sisaWaktu, this.gerakanSelanjutnya);

  @override
  List<Object?> get props => [sisaWaktu, gerakanSelanjutnya];
}

// Fase 2: Eksekusi gerakan dengan timer berjalan (FR-EXR-02)
class SesiBerjalan extends SesiLatihanState {
  final int sisaWaktu;
  final GerakanModel gerakanSaatIni;

  const SesiBerjalan(this.sisaWaktu, this.gerakanSaatIni);

  @override
  List<Object?> get props => [sisaWaktu, gerakanSaatIni];
}

// Fase 3: Jeda transisi antar-gerakan (FR-EXR-03)
class SesiTransisi extends SesiLatihanState {
  final int sisaWaktu;
  final GerakanModel gerakanSelanjutnya;

  const SesiTransisi(this.sisaWaktu, this.gerakanSelanjutnya);

  @override
  List<Object?> get props => [sisaWaktu, gerakanSelanjutnya];
}

// Fase 4: Sesi selesai, siap memunculkan Modal (FR-EXR-04)
class SesiSelesai extends SesiLatihanState {}

// Fase Darurat: Pengguna menekan tombol "X" atau "Kembali"
class SesiDibatalkan extends SesiLatihanState {}