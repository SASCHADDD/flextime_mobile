import 'package:equatable/equatable.dart';

class NotifikasiModel extends Equatable {
  final int id;
  final String judul;
  final String pesan;
  final String tipe; // success, info, warning, error
  final bool isRead;
  final String createdAt;

  const NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? 'info',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, judul, pesan, tipe, isRead, createdAt];
}
