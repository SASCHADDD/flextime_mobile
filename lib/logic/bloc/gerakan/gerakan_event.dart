import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class GerakanEvent extends Equatable {
  const GerakanEvent();

  @override
  List<Object?> get props => [];
}

class FetchGerakanRequested extends GerakanEvent {}

// [ADMIN] Event CRUD
class AddGerakan extends GerakanEvent {
  final String namaGerakan;
  final String deskripsi;
  final int durasiDetik;
  final File gambar;

  const AddGerakan({
    required this.namaGerakan,
    required this.deskripsi,
    required this.durasiDetik,
    required this.gambar,
  });

  @override
  List<Object?> get props => [namaGerakan, deskripsi, durasiDetik, gambar];
}

class UpdateGerakan extends GerakanEvent {
  final int id;
  final String namaGerakan;
  final String deskripsi;
  final int durasiDetik;
  final File? gambar;

  const UpdateGerakan({
    required this.id,
    required this.namaGerakan,
    required this.deskripsi,
    required this.durasiDetik,
    this.gambar,
  });

  @override
  List<Object?> get props => [id, namaGerakan, deskripsi, durasiDetik, gambar];
}

class DeleteGerakan extends GerakanEvent {
  final int id;

  const DeleteGerakan(this.id);

  @override
  List<Object?> get props => [id];
}