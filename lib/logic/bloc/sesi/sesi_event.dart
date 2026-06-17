import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';

abstract class SesiLatihanEvent extends Equatable {
  const SesiLatihanEvent();

  @override
  List<Object> get props => [];
}

// Memicu dimulainya sesi dengan membawa daftar gerakan dari GerakanBloc
class MulaiSesiRequested extends SesiLatihanEvent {
  final List<GerakanModel> daftarGerakan;

  const MulaiSesiRequested(this.daftarGerakan);

  @override
  List<Object> get props => [daftarGerakan];
}

// Event internal untuk memperbarui UI setiap 1 detik
class DetakWaktu extends SesiLatihanEvent {
  final int sisaWaktu;
  const DetakWaktu(this.sisaWaktu);

  @override
  List<Object> get props => [sisaWaktu];
}

// Event internal saat timer habis untuk memicu perpindahan fase
class WaktuHabis extends SesiLatihanEvent {}

// Memicu pembatalan darurat (Emergency Stop)
class BatalkanSesiRequested extends SesiLatihanEvent {}