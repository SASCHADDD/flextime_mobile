import 'package:flextime_mobile/data/models/notifikasi/notifikasi_model.dart';
import 'package:flextime_mobile/data/providers/notifikasi/notifikasi_api_provider.dart';

class NotifikasiRepository {
  final NotifikasiApiProvider apiProvider;

  NotifikasiRepository({required this.apiProvider});

  Future<List<NotifikasiModel>> fetchNotifikasi() async {
    final data = await apiProvider.getNotifikasi();
    return data.map((json) => NotifikasiModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(int id) async {
    await apiProvider.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await apiProvider.markAllAsRead();
  }
}
