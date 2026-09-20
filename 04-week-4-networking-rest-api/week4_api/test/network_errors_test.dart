import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/network_errors.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('mengembalikan pesan timeout yang tepat', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = friendlyErrorMessage(error);
      expect(message, contains('Waktu koneksi habis'));
    });

    test('mengembalikan pesan connection error yang tepat', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );

      final message = friendlyErrorMessage(error);
      expect(message, contains('Tidak dapat terhubung ke server'));
    });

    test('mengembalikan pesan 404 data tidak ditemukan', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 404,
        ),
      );

      final message = friendlyErrorMessage(error);
      expect(message, contains('Data tidak ditemukan'));
      expect(message, contains('404'));
    });

    test('mengembalikan pesan server error 500', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 500,
        ),
      );

      final message = friendlyErrorMessage(error);
      expect(message, contains('masalah pada server'));
      expect(message, contains('500'));
    });

    test('mengembalikan pesan default untuk non-DioException', () {
      final error = Exception('General failure');
      final message = friendlyErrorMessage(error);
      expect(message, contains('Terjadi kesalahan tak terduga'));
    });
  });
}
