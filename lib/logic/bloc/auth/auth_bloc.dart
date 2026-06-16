import 'package:flextime_mobile/data/repositories/auth/auth_repository.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_event.dart';
import 'package:flextime_mobile/logic/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Mendaftarkan penghubung antara Event dan Fungsi Logika
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  // --- LOGIKA CEK SESI (SPLASH SCREEN) ---
  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final hasToken = await authRepository.hasValidSession();
    if (hasToken) {
      emit(const AuthAuthenticated()); // Lempar ke Dashboard
    } else {
      emit(AuthUnauthenticated()); // Lempar ke Login Screen
    }
  }

  // --- LOGIKA LOGIN ---
  Future<void> _onAuthLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Munculkan loading spinner di UI
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user: user)); // Login sukses, bawa data user
    } catch (e) {
      // Menghapus teks "Exception: " bawaan Dart agar pesan dari Node.js terlihat bersih
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // --- LOGIKA REGISTER ---
  Future<void> _onAuthRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        event.namaLengkap,
        event.email,
        event.password,
        event.waktuMulaiKerja,
        event.waktuSelesaiKerja,
        event.waktuMulaiIstirahat,
        event.waktuSelesaiIstirahat,
      );
      emit(AuthRegisterSuccess()); // Register sukses, UI bisa pindah ke Login
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // --- LOGIKA LOGOUT ---
  Future<void> _onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated()); // Sesi dihapus, lempar kembali ke Login Screen
  }
}