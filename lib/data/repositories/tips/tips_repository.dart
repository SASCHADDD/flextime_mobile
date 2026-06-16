import 'package:flextime_mobile/data/models/tips/tips_model.dart';
import 'package:flextime_mobile/data/providers/api_provider.dart';

class TipsRepository {
  final ApiProvider apiProvider;

  TipsRepository({required this.apiProvider});

  Future<List<TipsModel>> getTips() async {
    // Menembak endpoint GET /tips di Express.js Anda
    final responseRaw = await apiProvider.get('/tips');
    
    // Pastikan backend Anda mengirimkan data dalam bentuk array (List)
    final List<dynamic> data = responseRaw['data'] ?? responseRaw;
    
    // Mengubah array JSON mentah menjadi List<TipsModel>
    return data.map((json) => TipsModel.fromJson(json)).toList();
  }
}