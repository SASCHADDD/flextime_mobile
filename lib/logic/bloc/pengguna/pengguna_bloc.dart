import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flextime_mobile/data/repositories/pengguna/pengguna_repository.dart';
import 'package:flextime_mobile/services/notification_service.dart';
import 'pengguna_event.dart';
import 'pengguna_state.dart';

class PenggunaBloc extends Bloc<PenggunaEvent, PenggunaState> {
  final PenggunaRepository penggunaRepository;

  PenggunaBloc({required this.penggunaRepository}) : super(PenggunaInitial()) {
    on<FetchProfilRequested>(_onFetchProfilRequested);
    on<UpdateProfilRequested>(_onUpdateProfilRequested);
    on<FetchAllPenggunaRequested>(_onFetchAllPenggunaRequested);
  }

  Future<void> _onFetchProfilRequested(FetchProfilRequested event, Emitter<PenggunaState> emit) async {
    emit(PenggunaLoading());
    try {
      final user = await penggunaRepository.getMe();
      emit(PenggunaProfilLoaded(user));
      
      if (user.jadwalMicrobreak.isNotEmpty) {
        NotificationService().scheduleMicrobreaks(user.jadwalMicrobreak);
      }
    } catch (e) {
      emit(PenggunaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfilRequested(UpdateProfilRequested event, Emitter<PenggunaState> emit) async {
    emit(PenggunaLoading());
    try {
      final updatedUser = await penggunaRepository.updateMe(
        namaLengkap: event.namaLengkap,
        jamMasukKerja: event.jamMasukKerja,
        jamKeluarKerja: event.jamKeluarKerja,
        jamMulaiIstirahat: event.jamMulaiIstirahat,
        jamSelesaiIstirahat: event.jamSelesaiIstirahat,
      );
      emit(PenggunaUpdateSuccess(updatedUser));
      // Re-fetch automatically
      add(FetchProfilRequested());
    } catch (e) {
      emit(PenggunaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchAllPenggunaRequested(FetchAllPenggunaRequested event, Emitter<PenggunaState> emit) async {
    emit(PenggunaLoading());
    try {
      final response = await penggunaRepository.getAllPengguna(search: event.query);
      emit(PenggunaListLoaded(
        users: response['users'],
        total: response['total'],
      ));
    } catch (e) {
      emit(PenggunaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}