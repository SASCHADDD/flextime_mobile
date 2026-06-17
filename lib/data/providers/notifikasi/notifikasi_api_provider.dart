import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';

class NotifikasiApiProvider {
  final StorageProvider storageProvider;

  NotifikasiApiProvider({required this.storageProvider});

  Future<List<dynamic>> getNotifikasi() async {
    final token = await storageProvider.getToken();
    if (token == null) throw Exception('Tidak ada token autentikasi.');

    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/notifikasi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Gagal memuat notifikasi');
    }
  }

  Future<dynamic> markAsRead(int id) async {
    final token = await storageProvider.getToken();
    if (token == null) throw Exception('Tidak ada token autentikasi.');

    final response = await http.put(
      Uri.parse('${ApiProvider.baseUrl}/notifikasi/$id/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Gagal menandai notifikasi');
    }
  }

  Future<void> markAllAsRead() async {
    final token = await storageProvider.getToken();
    if (token == null) throw Exception('Tidak ada token autentikasi.');

    final response = await http.put(
      Uri.parse('${ApiProvider.baseUrl}/notifikasi/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Gagal menandai semua notifikasi');
    }
  }
}
