import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';

abstract class GerakanState extends Equatable {
  const GerakanState();

  @override
  List<Object?> get props => [];
}

class GerakanInitial extends GerakanState {}

class GerakanLoading extends GerakanState {}

class GerakanLoaded extends GerakanState {
  final List<GerakanModel> gerakanList;

  const GerakanLoaded(this.gerakanList);

  @override
  List<Object?> get props => [gerakanList];
}

class GerakanOperationSuccess extends GerakanState {
  final String message;

  const GerakanOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class GerakanError extends GerakanState {
  final String message;

  const GerakanError(this.message);

  @override
  List<Object?> get props => [message];
}