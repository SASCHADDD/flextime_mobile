import 'package:flextime_mobile/data/models/auth/user_model.dart';
import 'package:flextime_mobile/data/providers/api_provider.dart';
import 'package:flextime_mobile/data/providers/storage_provider.dart';

class AuthRepository {
  final ApiProvider apiProvider;
  final StorageProvider storageProvider;
  // Menyuntikkan provider agar repository bisa menggunakan fitur jaringan dan penyimpanan
  AuthRepository({
    required this.apiProvider,
    required this.storageProvider,
  });

  // FUNGSI LOGIN
  // Mengirim kredensial ke API, menyimpan token jika sukses, dan mengembalikan data User
  Future<UserModel> login(String email, String password) async {
    final responseRaw = await apiProvider.post('/auth/login', {
      'email': email,
      'kata_sandi': password, 
    });
    
    // Mencetak JSON mentah menjadi objek Dart menggunakan Model Respons
    final responseModel = AuthResponseModel.fromJson(responseRaw);

    // Validasi keberhasilan dan kelengkapan data
    if (responseModel.success && responseModel.token != null && responseModel.user != null) {
      await storageProvider.saveToken(responseModel.token!);
      // Kembalikan data pengguna ke BLoC
      return responseModel.user!;
    } else {
      throw Exception(responseModel.message);
    }
  }

  // FUNGSI REGISTER
  // Mendaftarkan pengguna baru ke database
  Future<void> register(
    String namaLengkap,
    String email,
    String password,
    String waktuMulaiKerja,
    String waktuSelesaiKerja,
    String waktuMulaiIstirahat,
    String waktuSelesaiIstirahat,
  ) async {
    await apiProvider.post('/auth/register', {
      'nama_lengkap': namaLengkap, 
      'email': email,
      'kata_sandi': password,
      'waktu_mulai_kerja': waktuMulaiKerja,
      'waktu_selesai_kerja': waktuSelesaiKerja,
      'waktu_mulai_istirahat': waktuMulaiIstirahat,
      'waktu_selesai_istirahat': waktuSelesaiIstirahat,
    });
  }

  //FUNGSI LOGOUT (Menghapus sesi pengguna dari aplikasi)
  Future<void> logout() async {
    try {
      // await apiProvider.post('/auth/logout', {});
    } catch (e) {
      // menghapus token lokal pengguna.
    } finally {
      //Hapus token dari memori fisik HP
      await storageProvider.deleteToken();
    }
  }

  //FUNGSI CEK STATUS SESI (Untuk Splash Screen)
  // Mengembalikan true jika pengguna memiliki token aktif di HP
  Future<bool> hasValidSession() async {
    return await storageProvider.hasToken();
  }
}