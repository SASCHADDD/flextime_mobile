import 'package:equatable/equatable.dart';

class RiwayatModel extends Equatable {
  final int id;
  final int penggunaId;
  final int gerakanId;
  final String sesi;
  final String statusKepatuhan;
  final int durasiDetik;
  final String? tanggal; // <-- ADDED
  final String? dibuatPada;
  final String? diperbaruiPada;

  final String? namaPengguna;
  final String? namaGerakan;
  final String? gambarGerakan;

  const RiwayatModel({
    required this.id,
    required this.penggunaId,
    required this.gerakanId,
    required this.sesi,
    required this.statusKepatuhan,
    required this.durasiDetik,
    this.tanggal, // <-- ADDED
    this.dibuatPada,
    this.diperbaruiPada,
    this.namaPengguna,
    this.namaGerakan,
    this.gambarGerakan,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    final dataPengguna = json['pengguna'];
    final dataGerakan = json['gerakan'];

    return RiwayatModel(
      id: json['id'] ?? 0,
      penggunaId: json['pengguna_id'] ?? 0,
      gerakanId: json['gerakan_id'] ?? 0,
      sesi: json['sesi'] ?? '',
      statusKepatuhan: json['status_kepatuhan'] ?? 'Tidak',
      durasiDetik: json['durasi_detik'] != null 
          ? int.tryParse(json['durasi_detik'].toString()) ?? 0 
          : 0,
      tanggal: json['tanggal'], // <-- ADDED
      dibuatPada: json['dibuat_pada'],
      diperbaruiPada: json['diperbarui_pada'],
      
      namaPengguna: dataPengguna != null ? dataPengguna['nama_lengkap'] : null,
      namaGerakan: dataGerakan != null ? dataGerakan['nama_gerakan'] : null,
      gambarGerakan: dataGerakan != null ? dataGerakan['gambar'] : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        penggunaId,
        gerakanId,
        sesi,
        statusKepatuhan,
        durasiDetik,
        tanggal, // <-- ADDED
        dibuatPada,
        diperbaruiPada,
        namaPengguna,
        namaGerakan,
        gambarGerakan,
      ];
}

// digunakan saat menampilkan semua data (get all)

class RiwayatListResponseModel extends Equatable {
  final bool success;
  final String? message;
  final List<RiwayatModel> data;

  const RiwayatListResponseModel({
    required this.success,
    this.message,
    required this.data,
  });

  factory RiwayatListResponseModel.fromJson(Map<String, dynamic> json) {
    return RiwayatListResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? List<RiwayatModel>.from(
              json['data'].map((x) => RiwayatModel.fromJson(x)))
          : [],
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
// digunakan saat getbyid, create,update

class RiwayatSingleResponseModel extends Equatable {
  final bool success;
  final String? message;
  final RiwayatModel? data;

  const RiwayatSingleResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory RiwayatSingleResponseModel.fromJson(Map<String, dynamic> json) {
    return RiwayatSingleResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? RiwayatModel.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}