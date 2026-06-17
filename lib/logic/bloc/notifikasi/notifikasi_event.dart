import 'package:equatable/equatable.dart';

abstract class NotifikasiEvent extends Equatable {
  const NotifikasiEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifikasiRequested extends NotifikasiEvent {}

class MarkAllReadRequested extends NotifikasiEvent {}

class MarkReadRequested extends NotifikasiEvent {
  final int id;
  const MarkReadRequested(this.id);

  @override
  List<Object> get props => [id];
}
