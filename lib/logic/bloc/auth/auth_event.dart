import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// 1. Dipicu oleh Splash Screen untuk mengecek apakah ada token yang tersimpan
class AuthCheckRequested extends AuthEvent {}

// 2. Dipicu saat tombol "Login" ditekan
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// 3. Dipicu saat tombol "Daftar" ditekan
class AuthRegisterRequested extends AuthEvent {
  final String namaLengkap;
  final String email;
  final String password;
  final String waktuMulaiKerja;
  final String waktuSelesaiKerja;
  final String waktuMulaiIstirahat;
  final String waktuSelesaiIstirahat;

  const AuthRegisterRequested(
    this.namaLengkap,
    this.email,
    this.password,
    this.waktuMulaiKerja,
    this.waktuSelesaiKerja,
    this.waktuMulaiIstirahat,
    this.waktuSelesaiIstirahat,
  );

  @override
  List<Object> get props => [
        namaLengkap,
        email,
        password,
        waktuMulaiKerja,
        waktuSelesaiKerja,
        waktuMulaiIstirahat,
        waktuSelesaiIstirahat,
      ];
}

// 4. Dipicu saat tombol "Keluar" ditekan dari halaman Profil/Dashboard
class AuthLogoutRequested extends AuthEvent {}