import 'package:equatable/equatable.dart';

abstract class RiwayatEvent extends Equatable {
  const RiwayatEvent();

  @override
  List<Object?> get props => [];
}

class FetchRiwayatRequested extends RiwayatEvent {
  final String filter; // Contoh: 'harian', 'mingguan', 'bulanan'

  const FetchRiwayatRequested({this.filter = 'harian'});

  @override
  List<Object?> get props => [filter];
}

class FetchRiwayatAdminRequested extends RiwayatEvent {
  final int penggunaId;

  const FetchRiwayatAdminRequested(this.penggunaId);

  @override
  List<Object?> get props => [penggunaId];
}

class TambahRiwayatRequested extends RiwayatEvent {
  final Map<String, dynamic> data;

  const TambahRiwayatRequested(this.data);

  @override
  List<Object?> get props => [data];
}
