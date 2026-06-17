import 'package:flextime_mobile/data/models/auth/user_model.dart';
import 'package:flextime_mobile/data/providers/api_provider.dart';

class PenggunaRepository {
  final ApiProvider apiProvider;

  PenggunaRepository({required this.apiProvider});

  // [USER/ADMIN] Mengambil profil sendiri
  Future<UserModel> getMe() async {
    final responseRaw = await apiProvider.get('/pengguna/me');
    return UserModel.fromJson(responseRaw['data']);
  }

  // [USER/ADMIN] Memperbarui biodata dan jam kerja
  Future<UserModel> updateMe({
    String? namaLengkap,
    String? jamMasukKerja,
    String? jamKeluarKerja,
    String? jamMulaiIstirahat,
    String? jamSelesaiIstirahat,
  }) async {
    final Map<String, dynamic> body = {};
    if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
    if (jamMasukKerja != null) body['jam_masuk_kerja'] = jamMasukKerja;
    if (jamKeluarKerja != null) body['jam_keluar_kerja'] = jamKeluarKerja;
    if (jamMulaiIstirahat != null) body['jam_mulai_istirahat'] = jamMulaiIstirahat;
    if (jamSelesaiIstirahat != null) body['jam_selesai_istirahat'] = jamSelesaiIstirahat;

    final responseRaw = await apiProvider.put('/pengguna/me', body);
    return UserModel.fromJson(responseRaw['data']);
  }

  // [ADMIN] Mengambil semua pengguna (bisa dengan search query)
  Future<Map<String, dynamic>> getAllPengguna({String search = '', int page = 1, int limit = 15}) async {
    final responseRaw = await apiProvider.get('/pengguna?page=$page&limit=$limit&search=$search');
    
    final List<dynamic> data = responseRaw['data'] ?? [];
    final List<UserModel> users = data.map((json) => UserModel.fromJson(json)).toList();
    final int total = responseRaw['pagination']?['total_items'] ?? users.length;

    return {
      'users': users,
      'total': total,
    };
  }
}