import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flextime_mobile/data/repositories/gerakan/gerakan_repository.dart';
import 'gerakan_event.dart';
import 'gerakan_state.dart';

class GerakanBloc extends Bloc<GerakanEvent, GerakanState> {
  final GerakanRepository gerakanRepository;

  GerakanBloc({required this.gerakanRepository}) : super(GerakanInitial()) {
    on<FetchGerakanRequested>(_onFetchGerakan);
    on<AddGerakan>(_onAddGerakan);
    on<UpdateGerakan>(_onUpdateGerakan);
    on<DeleteGerakan>(_onDeleteGerakan);
  }

  Future<void> _onFetchGerakan(FetchGerakanRequested event, Emitter<GerakanState> emit) async {
    emit(GerakanLoading());
    try {
      final gerakanList = await gerakanRepository.getGerakan();
      emit(GerakanLoaded(gerakanList.reversed.toList()));
    } catch (e) {
      emit(GerakanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddGerakan(AddGerakan event, Emitter<GerakanState> emit) async {
    emit(GerakanLoading());
    try {
      await gerakanRepository.createGerakan(
        namaGerakan: event.namaGerakan,
        deskripsi: event.deskripsi,
        durasiDetik: event.durasiDetik,
        gambar: event.gambar,
      );
      emit(const GerakanOperationSuccess('Gerakan berhasil ditambahkan!'));
      add(FetchGerakanRequested()); // Reload daftar gerakan
    } catch (e) {
      emit(GerakanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateGerakan(UpdateGerakan event, Emitter<GerakanState> emit) async {
    emit(GerakanLoading());
    try {
      await gerakanRepository.updateGerakan(
        id: event.id,
        namaGerakan: event.namaGerakan,
        deskripsi: event.deskripsi,
        durasiDetik: event.durasiDetik,
        gambar: event.gambar,
      );
      emit(const GerakanOperationSuccess('Gerakan berhasil diperbarui!'));
      add(FetchGerakanRequested());
    } catch (e) {
      emit(GerakanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteGerakan(DeleteGerakan event, Emitter<GerakanState> emit) async {
    emit(GerakanLoading());
    try {
      await gerakanRepository.deleteGerakan(event.id);
      emit(const GerakanOperationSuccess('Gerakan berhasil dihapus!'));
      add(FetchGerakanRequested());
    } catch (e) {
      emit(GerakanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}