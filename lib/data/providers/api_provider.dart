import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flextime_mobile/data/providers/storage_provider.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  //  10.0.2.2 untuk Emulator Android, atau 127.0.0.1 untuk iOS Simulator
  static const String baseUrl = 'http://127.0.0.1:3000/api'; 
  
  final StorageProvider _storageProvider = StorageProvider();

  //Menyiapkan Header dan menyisipkan Token JWT jika ada
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await _storageProvider.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET (Mengambil Data)
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      developer.log('GET $endpoint | Status: ${response.statusCode}', name: 'API_GET');
      return _processResponse(response);
    } catch (e) {
      developer.log('Error GET $endpoint: $e', name: 'API_ERROR');
      rethrow;
    }
  }

  // POST (Kirim Data Baru / Login)
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      developer.log('POST $endpoint | Status: ${response.statusCode}', name: 'API_POST');
      return _processResponse(response);
    } catch (e) {
      developer.log('Error POST $endpoint: $e', name: 'API_ERROR');
      rethrow;
    }
  }

  // PUT (Memperbarui Data)
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      developer.log('PUT $endpoint | Status: ${response.statusCode}', name: 'API_PUT');
      return _processResponse(response);
    } catch (e) {
      developer.log('Error PUT $endpoint: $e', name: 'API_ERROR');
      rethrow;
    }
  }

  // DELETE (Menghapus Data)
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      developer.log('DELETE $endpoint | Status: ${response.statusCode}', name: 'API_DELETE');
      return _processResponse(response);
    } catch (e) {
      developer.log('Error DELETE $endpoint: $e', name: 'API_ERROR');
      rethrow;
    }
  }

  // Memproses Respons dari Server Node.js
  dynamic _processResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);

    // Jika status 200 - 299 (Berhasil)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Jika status 400/500, lempar pesan error spesifik dari backend
      throw Exception(responseBody['message'] ?? 'Terjadi kesalahan pada server');
    }
  }
}