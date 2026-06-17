import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:flextime_mobile/data/models/gerakan/gerakan_model.dart';
import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';

class GerakanRepository {
  final ApiProvider apiProvider;

  GerakanRepository({required this.apiProvider});

  Future<List<GerakanModel>> getGerakan() async {
    final responseRaw = await apiProvider.get('/gerakan');
    
    final List<dynamic> data = responseRaw['data'] ?? responseRaw;
    return data.map((json) => GerakanModel.fromJson(json)).toList();
  }

  // CREATE Gerakan
  Future<GerakanModel> createGerakan({
    required String namaGerakan,
    required String deskripsi,
    required int durasiDetik,
    required File gambar,
  }) async {
    final token = await StorageProvider().getToken();
    final uri = Uri.parse('${ApiProvider.baseUrl}/gerakan');
    
    var request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['nama_gerakan'] = namaGerakan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['durasi_detik'] = durasiDetik.toString();

    // Menyiapkan file gambar
    var pic = await http.MultipartFile.fromPath(
      'gambar',
      gambar.path,
      contentType: MediaType('image', 'jpeg'), // Asumsi jpeg/png
    );
    request.files.add(pic);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = jsonDecode(response.body);
        return GerakanModel.fromJson(jsonResponse['data']);
      } catch (e) {
        throw Exception('Server returned invalid JSON: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}');
      }
    } else {
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Gagal membuat gerakan');
      } catch (e) {
        throw Exception('Server Error (${response.statusCode}): ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}');
      }
    }
  }

  // UPDATE Gerakan
  Future<GerakanModel> updateGerakan({
    required int id,
    required String namaGerakan,
    required String deskripsi,
    required int durasiDetik,
    File? gambar,
  }) async {
    final token = await StorageProvider().getToken();
    final uri = Uri.parse('${ApiProvider.baseUrl}/gerakan/$id');
    
    var request = http.MultipartRequest('PUT', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['nama_gerakan'] = namaGerakan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['durasi_detik'] = durasiDetik.toString();

    if (gambar != null) {
      var pic = await http.MultipartFile.fromPath(
        'gambar',
        gambar.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(pic);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = jsonDecode(response.body);
        return GerakanModel.fromJson(jsonResponse['data']);
      } catch (e) {
        throw Exception('Server returned invalid JSON: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}');
      }
    } else {
      try {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Gagal memperbarui gerakan');
      } catch (e) {
        throw Exception('Server Error (${response.statusCode}): ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}');
      }
    }
  }

  // DELETE Gerakan
  Future<void> deleteGerakan(int id) async {
    await apiProvider.delete('/gerakan/$id');
  }
}