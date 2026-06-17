import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flextime_mobile/data/repositories/notifikasi/notifikasi_repository.dart';
import 'notifikasi_event.dart';
import 'notifikasi_state.dart';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  final NotifikasiRepository notifikasiRepository;

  NotifikasiBloc({required this.notifikasiRepository}) : super(NotifikasiInitial()) {
    on<FetchNotifikasiRequested>(_onFetchNotifikasi);
    on<MarkReadRequested>(_onMarkRead);
    on<MarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onFetchNotifikasi(FetchNotifikasiRequested event, Emitter<NotifikasiState> emit) async {
    emit(NotifikasiLoading());
    try {
      final notifikasi = await notifikasiRepository.fetchNotifikasi();
      emit(NotifikasiLoaded(notifikasi));
    } catch (e) {
      emit(NotifikasiError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkRead(MarkReadRequested event, Emitter<NotifikasiState> emit) async {
    try {
      await notifikasiRepository.markAsRead(event.id);
      add(FetchNotifikasiRequested());
    } catch (e) {
      // diam diam error, atau tunjukkan error
      emit(NotifikasiError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkAllRead(MarkAllReadRequested event, Emitter<NotifikasiState> emit) async {
    try {
      await notifikasiRepository.markAllAsRead();
      add(FetchNotifikasiRequested());
    } catch (e) {
      emit(NotifikasiError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
