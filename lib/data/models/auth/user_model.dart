import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String namaLengkap;
  final String email;
  final String jamMasukKerja;
  final String jamKeluarKerja;
  final String jamMulaiIstirahat;
  final String jamSelesaiIstirahat;
  final String peran;
  final List<String> jadwalMicrobreak;

  const UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.jamMasukKerja,
    required this.jamKeluarKerja,
    required this.jamMulaiIstirahat,
    required this.jamSelesaiIstirahat,
    required this.peran,
    required this.jadwalMicrobreak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      jamMasukKerja: json['jam_masuk_kerja'] ?? '08:00:00',
      jamKeluarKerja: json['jam_keluar_kerja'] ?? '17:00:00',
      jamMulaiIstirahat: json['jam_mulai_istirahat'] ?? '12:00:00',
      jamSelesaiIstirahat: json['jam_selesai_istirahat'] ?? '13:00:00',
      peran: json['peran'] ?? json['role'] ?? 'user',
      jadwalMicrobreak: (json['jadwal_microbreak'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaLengkap,
        email,
        jamMasukKerja,
        jamKeluarKerja,
        jamMulaiIstirahat,
        jamSelesaiIstirahat,
        peran,
        jadwalMicrobreak,
      ];
}

class AuthResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Terjadi kesalahan tidak dikenal',
      token: data != null ? data['token'] : null,
      user: (data != null && data['user'] != null) 
          ? UserModel.fromJson(data['user']) 
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, token, user];
}