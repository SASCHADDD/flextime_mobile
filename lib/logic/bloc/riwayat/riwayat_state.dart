import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/riwayat/riwayat_model.dart';

abstract class RiwayatState extends Equatable {
  const RiwayatState();

  @override
  List<Object?> get props => [];
}

class RiwayatInitial extends RiwayatState {}

class RiwayatLoading extends RiwayatState {}

class RiwayatLoaded extends RiwayatState {
  final List<RiwayatModel> riwayatList;

  const RiwayatLoaded(this.riwayatList);

  @override
  List<Object?> get props => [riwayatList];
}

class RiwayatError extends RiwayatState {
  final String message;

  const RiwayatError(this.message);

  @override
  List<Object?> get props => [message];
}
