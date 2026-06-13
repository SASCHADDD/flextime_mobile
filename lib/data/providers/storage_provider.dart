import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider {
  // Kata kunci absolut untuk laci token
  static const String _tokenKey = 'jwt_token';

  // Menyimpan token ke memori perangkat
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Membaca token dari memori perangkat
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Mengecek apakah token ada (berguna untuk logika Splash Screen)
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Menghapus token (saat pengguna Logout)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}