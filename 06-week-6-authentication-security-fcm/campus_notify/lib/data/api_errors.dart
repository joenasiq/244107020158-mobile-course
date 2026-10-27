// Pemetaan DioException → pesan ramah pengguna (Refactoring Challenge #3).
//
// UI hanya menerima String dari fungsi ini, tidak exception mentah.
import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server terlalu lama. Periksa jaringan Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan internet aktif.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Sesi habis. Silakan login kembali.';
        if (code == 403) return 'Akses ditolak.';
        if (code == 404) return 'Data tidak ditemukan.';
        if (code == 500) return 'Server sedang bermasalah. Coba lagi nanti.';
        return 'Server merespons dengan kode $code.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.unknown:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
      default:
        return 'Kesalahan jaringan tidak dikenal.';
    }
  }
  // Bukan DioException — tampilkan pesan asli tanpa prefix "Exception:".
  return error.toString().replaceAll('Exception: ', '');
}
