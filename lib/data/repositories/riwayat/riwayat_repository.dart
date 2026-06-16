import 'package:flextime_mobile/data/models/riwayat/riwayat_model.dart';
import 'package:flextime_mobile/data/providers/api_provider.dart';

class RiwayatRepository {
  final ApiProvider apiProvider;

  RiwayatRepository({required this.apiProvider});

  Future<List<RiwayatModel>> getRiwayat({String? filter}) async {
    // Menambahkan filter jika ada, default kosong
    final query = filter != null && filter.isNotEmpty ? '?filter=$filter' : '';
    final responseRaw = await apiProvider.get('/riwayat$query');
    
    // Pastikan backend mengirimkan data dalam bentuk array
    final List<dynamic> data = responseRaw['data'] ?? responseRaw;
    
    return data.map((json) => RiwayatModel.fromJson(json)).toList();
  }
}
