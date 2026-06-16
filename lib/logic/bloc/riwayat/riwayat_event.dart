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
