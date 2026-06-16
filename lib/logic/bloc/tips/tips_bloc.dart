import 'package:flextime_mobile/data/repositories/tips/tips_repository.dart';
import 'package:flextime_mobile/logic/bloc/tips/tips_event.dart';
import 'package:flextime_mobile/logic/bloc/tips/tips_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TipsBloc extends Bloc<TipsEvent, TipsState> {
  final TipsRepository tipsRepository;

  TipsBloc({required this.tipsRepository}) : super(TipsInitial()) {
    on<FetchTipsRequested>(_onFetchTipsRequested);
  }

  Future<void> _onFetchTipsRequested(FetchTipsRequested event, Emitter<TipsState> emit) async {
    emit(TipsLoading()); // Menampilkan skeleton/spinner di UI
    try {
      // Meminta repository untuk mengambil data dari backend Node.js
      final tipsList = await tipsRepository.getTips();
      
      // Jika kosong, bisa diatur opsional apakah mau memunculkan error atau state kosong
      emit(TipsLoaded(tipsList));
    } catch (e) {
      emit(TipsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}