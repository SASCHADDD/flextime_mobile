import 'package:equatable/equatable.dart';

class GerakanModel extends Equatable {
  final int id;
  final String namaGerakan;
  final String deskripsi;
  final int durasiDetik;
  final String? gambar; 
  final String? dibuatPada;
  final String? diperbaruiPada;

  const GerakanModel({
    required this.id,
    required this.namaGerakan,
    required this.deskripsi,
    required this.durasiDetik,
    this.gambar,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  factory GerakanModel.fromJson(Map<String, dynamic> json) {
    return GerakanModel(
      id: json['id'] ?? 0,
      namaGerakan: json['nama_gerakan'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      durasiDetik: json['durasi_detik'] != null 
          ? int.tryParse(json['durasi_detik'].toString()) ?? 60 
          : 60,
      gambar: json['gambar'],
      dibuatPada: json['dibuat_pada'],
      diperbaruiPada: json['diperbarui_pada'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaGerakan,
        deskripsi,
        durasiDetik,
        gambar,
        dibuatPada,
        diperbaruiPada,
      ];
}
//digunakan saat menampilkan semua (get all)
class GerakanListResponseModel extends Equatable {
  final bool success;
  final String? message;
  final List<GerakanModel> data;

  const GerakanListResponseModel({
    required this.success,
    this.message,
    required this.data,
  });

  factory GerakanListResponseModel.fromJson(Map<String, dynamic> json) {
    return GerakanListResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? List<GerakanModel>.from(
              json['data'].map((x) => GerakanModel.fromJson(x)))
          : [],
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
//digunakan saat getbyid,update,tambah.
class GerakanSingleResponseModel extends Equatable {
  final bool success;
  final String? message;
  final GerakanModel? data;

  const GerakanSingleResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory GerakanSingleResponseModel.fromJson(Map<String, dynamic> json) {
    return GerakanSingleResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? GerakanModel.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}