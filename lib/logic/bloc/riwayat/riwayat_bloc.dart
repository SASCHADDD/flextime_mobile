import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flextime_mobile/data/repositories/riwayat/riwayat_repository.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_event.dart';
import 'package:flextime_mobile/logic/bloc/riwayat/riwayat_state.dart';

class RiwayatBloc extends Bloc<RiwayatEvent, RiwayatState> {
  final RiwayatRepository riwayatRepository;

  RiwayatBloc({required this.riwayatRepository}) : super(RiwayatInitial()) {
    on<FetchRiwayatRequested>(_onFetchRiwayatRequested);
  }

  Future<void> _onFetchRiwayatRequested(FetchRiwayatRequested event, Emitter<RiwayatState> emit) async {
    emit(RiwayatLoading());
    try {
      // Panggil repository untuk mengambil data riwayat dengan filter
      final riwayatList = await riwayatRepository.getRiwayat(filter: event.filter);
      emit(RiwayatLoaded(riwayatList));
    } catch (e) {
      if (e.toString().contains('DOCTYPE html')) {
        emit(const RiwayatError('Gagal memuat riwayat: Endpoint backend belum aktif atau tidak ditemukan.'));
      } else {
        emit(RiwayatError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}
