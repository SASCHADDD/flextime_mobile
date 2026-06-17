import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/auth/user_model.dart';

abstract class PenggunaState extends Equatable {
  const PenggunaState();

  @override
  List<Object?> get props => [];
}

class PenggunaInitial extends PenggunaState {}

class PenggunaLoading extends PenggunaState {}

// State untuk Profil Sendiri
class PenggunaProfilLoaded extends PenggunaState {
  final UserModel user;

  const PenggunaProfilLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class PenggunaUpdateSuccess extends PenggunaState {
  final UserModel user;

  const PenggunaUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// State untuk Daftar Pengguna (Admin)
class PenggunaListLoaded extends PenggunaState {
  final List<UserModel> users;
  final int total;

  const PenggunaListLoaded({required this.users, required this.total});

  @override
  List<Object?> get props => [users, total];
}

class PenggunaError extends PenggunaState {
  final String message;

  const PenggunaError(this.message);

  @override
  List<Object?> get props => [message];
}