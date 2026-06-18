import 'package:flextime_mobile/data/models/auth/user_model.dart';
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
    on<LoadMorePenggunaRequested>(_onLoadMorePenggunaRequested);
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
      final response = await penggunaRepository.getAllPengguna(search: event.query, page: 1);
      final List<UserModel> users = response['users'];
      emit(PenggunaListLoaded(
        users: users,
        total: response['total'],
        searchQuery: event.query,
        currentPage: 1,
        hasReachedMax: users.length < 15,
      ));
    } catch (e) {
      emit(PenggunaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMorePenggunaRequested(LoadMorePenggunaRequested event, Emitter<PenggunaState> emit) async {
    final currentState = state;
    if (currentState is PenggunaListLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await penggunaRepository.getAllPengguna(
          search: currentState.searchQuery,
          page: nextPage,
        );
        final List<UserModel> newUsers = response['users'];
        
        emit(currentState.copyWith(
          users: List.of(currentState.users)..addAll(newUsers),
          currentPage: nextPage,
          hasReachedMax: newUsers.isEmpty || newUsers.length < 15,
        ));
      } catch (e) {
        // Abaikan error pada load more atau tangani dengan UI yang sesuai
      }
    }
  }
}