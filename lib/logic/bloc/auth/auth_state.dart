import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/auth/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// 1. Kondisi awal saat aplikasi baru dibuka
class AuthInitial extends AuthState {}

// 2. Kondisi saat sedang memuat (UI akan menampilkan ikon putar/spinner)
class AuthLoading extends AuthState {}

// 3. Kondisi saat login berhasil ATAU token masih aktif di Splash Screen
class AuthAuthenticated extends AuthState {
  final UserModel? user; // Bisa null jika hanya mengecek token di Splash Screen
  
  const AuthAuthenticated({this.user});

  @override
  List<Object?> get props => [user];
}

// 4. Kondisi saat token tidak ada atau user menekan logout
class AuthUnauthenticated extends AuthState {}

// 5. Kondisi khusus saat register berhasil (untuk memunculkan Snackbar sukses)
class AuthRegisterSuccess extends AuthState {}

// 6. Kondisi saat terjadi error dari Node.js (misal: "Kata sandi salah")
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}