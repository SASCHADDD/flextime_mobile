import 'package:equatable/equatable.dart';

class TipsModel extends Equatable {
  final int id;
  final String kondisiPemicu;
  final String judul;
  final String kontenPesan;

  const TipsModel({
    required this.id,
    required this.kondisiPemicu,
    required this.judul,
    required this.kontenPesan,
  });

  factory TipsModel.fromJson(Map<String, dynamic> json) {
    return TipsModel(
      id: json['id'] ?? 0,
      kondisiPemicu: json['kondisi_pemicu'] ?? '',
      judul: json['judul'] ?? '',
      kontenPesan: json['konten_pesan'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        kondisiPemicu,
        judul,
        kontenPesan,
      ];
}

class TipsListResponseModel extends Equatable {
  final bool success;
  final String? message;
  final List<TipsModel> data;

  const TipsListResponseModel({
    required this.success,
    this.message,
    required this.data,
  });

  factory TipsListResponseModel.fromJson(Map<String, dynamic> json) {
    return TipsListResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? List<TipsModel>.from(
              json['data'].map((x) => TipsModel.fromJson(x)))
          : [],
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class TipsSingleResponseModel extends Equatable {
  final bool success;
  final String? message;
  final TipsModel? data;

  const TipsSingleResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory TipsSingleResponseModel.fromJson(Map<String, dynamic> json) {
    return TipsSingleResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TipsModel.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}