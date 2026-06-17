// Enum internal untuk melacak kita sedang berada di fase mana
import 'dart:async';

import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_event.dart';
import 'package:flextime_mobile/logic/bloc/sesi/sesi_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FaseSesi { persiapan, berjalan, transisi }

class SesiLatihanBloc extends Bloc<SesiLatihanEvent, SesiLatihanState> {
  Timer? _timer;
  List<GerakanModel> _daftarGerakan = [];
  int _indeksSaatIni = 0;
  FaseSesi _faseSaatIni = FaseSesi.persiapan;

  // Parameter waktu default (idealnya bisa ditarik dari backend Admin nanti)
  final int _waktuPersiapan = 5;
  final int _waktuTransisi = 3;

  SesiLatihanBloc() : super(SesiLatihanInitial()) {
    on<MulaiSesiRequested>(_onMulaiSesi);
    on<DetakWaktu>(_onDetakWaktu);
    on<WaktuHabis>(_onWaktuHabis);
    on<BatalkanSesiRequested>(_onBatalkanSesi);
  }

  void _onMulaiSesi(MulaiSesiRequested event, Emitter<SesiLatihanState> emit) {
    if (event.daftarGerakan.isEmpty) return;
    
    _daftarGerakan = event.daftarGerakan;
    _indeksSaatIni = 0;
    
    _mulaiFasePersiapan(emit);
  }

  void _mulaiFasePersiapan(Emitter<SesiLatihanState> emit) {
    _faseSaatIni = FaseSesi.persiapan;
    _jalankanTimer(_waktuPersiapan);
    emit(SesiPersiapan(_waktuPersiapan, _daftarGerakan[_indeksSaatIni]));
  }

  void _mulaiFaseBerjalan(Emitter<SesiLatihanState> emit) {
    _faseSaatIni = FaseSesi.berjalan;
    final gerakan = _daftarGerakan[_indeksSaatIni];
    // Menggunakan durasi spesifik dari gerakan (FR-ADM-01)
    _jalankanTimer(gerakan.durasiDetik); 
    emit(SesiBerjalan(gerakan.durasiDetik, gerakan));
  }

  void _mulaiFaseTransisi(Emitter<SesiLatihanState> emit) {
    _faseSaatIni = FaseSesi.transisi;
    _indeksSaatIni++; // Naikkan indeks ke gerakan selanjutnya
    
    if (_indeksSaatIni >= _daftarGerakan.length) {
      // Jika indeks sudah melewati jumlah daftar gerakan, sesi selesai
      _timer?.cancel();
      emit(SesiSelesai());
    } else {
      _jalankanTimer(_waktuTransisi);
      emit(SesiTransisi(_waktuTransisi, _daftarGerakan[_indeksSaatIni]));
    }
  }

  // --- FUNGSI INTI PENGATUR TIMER ---
  void _jalankanTimer(int durasiAwal) {
    _timer?.cancel(); // Selalu matikan timer sebelumnya agar tidak bocor (memory leak)
    int sisaWaktu = durasiAwal;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      sisaWaktu--;
      if (sisaWaktu >= 0) {
        add(DetakWaktu(sisaWaktu)); // Lempar event agar UI memperbarui angka
      } else {
        timer.cancel(); // Waktu habis, hentikan timer ini
        add(WaktuHabis()); 
      }
    });
  }

  // Menangkap lemparan event _DetakWaktu untuk memancarkan State ke UI
  void _onDetakWaktu(DetakWaktu event, Emitter<SesiLatihanState> emit) {
    final gerakan = _daftarGerakan[_indeksSaatIni];
    switch (_faseSaatIni) {
      case FaseSesi.persiapan:
        emit(SesiPersiapan(event.sisaWaktu, gerakan));
        break;
      case FaseSesi.berjalan:
        emit(SesiBerjalan(event.sisaWaktu, gerakan));
        break;
      case FaseSesi.transisi:
        emit(SesiTransisi(event.sisaWaktu, gerakan));
        break;
    }
  }

  // Menangkap lemparan event WaktuHabis untuk pindah fase secara otomatis
  void _onWaktuHabis(WaktuHabis event, Emitter<SesiLatihanState> emit) {
    switch (_faseSaatIni) {
      case FaseSesi.persiapan:
        _mulaiFaseBerjalan(emit);
        break;
      case FaseSesi.berjalan:
        _mulaiFaseTransisi(emit);
        break;
      case FaseSesi.transisi:
        _mulaiFaseBerjalan(emit);
        break;
    }
  }

  // Kontrol Pembatalan Darurat (FR-SAF-02)
  void _onBatalkanSesi(BatalkanSesiRequested event, Emitter<SesiLatihanState> emit) {
    _timer?.cancel();
    emit(SesiDibatalkan());
  }

  @override
  Future<void> close() {
    _timer?.cancel(); // Wajib membersihkan timer saat memori aplikasi ditutup
    return super.close();
  }
}