import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/notifikasi/notifikasi_model.dart';

abstract class NotifikasiState extends Equatable {
  const NotifikasiState();
  
  @override
  List<Object> get props => [];
}

class NotifikasiInitial extends NotifikasiState {}

class NotifikasiLoading extends NotifikasiState {}

class NotifikasiLoaded extends NotifikasiState {
  final List<NotifikasiModel> notifikasi;
  final int unreadCount;

  NotifikasiLoaded(this.notifikasi)
      : unreadCount = notifikasi.where((n) => !n.isRead).length;

  @override
  List<Object> get props => [notifikasi, unreadCount];
}

class NotifikasiError extends NotifikasiState {
  final String message;

  const NotifikasiError(this.message);

  @override
  List<Object> get props => [message];
}
