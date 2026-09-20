import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      // 1. Penanganan Timeout (Connect, Send, Receive Timeout)
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (Timeout). Periksa koneksi internet Anda lalu coba lagi.';

      // 2. Penanganan Connection Error (Tidak ada internet / Server mati)
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

      // 3. Penanganan HTTP Status Code Response
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) {
          return 'Data tidak ditemukan (Error 404).';
        }
        if (code != null && code >= 500) {
          return 'Terjadi masalah pada server (Error $code). Silakan coba lagi nanti.';
        }
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Anda tidak memiliki izin.';
        }
        return 'Terjadi kesalahan pada respon server (Kode: $code).';

      default:
        return 'Terjadi kesalahan jaringan (${error.message ?? 'Unknown network error'}).';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
