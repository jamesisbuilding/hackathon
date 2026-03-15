import 'dart:developer';

import 'package:dio/dio.dart';

class PingApiClient {
  PingApiClient({required this.endpoint, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final String endpoint;
  final Dio _dio;

  /// Sends a batch of tap events.
  /// [taps] is a list of {tap_at (ms epoch), topic} entries.
  Future<void> sendScrollDownPing({
    required String uid,
    required List<Map<String, dynamic>> taps,
  }) async {
    await _dio.post<void>(
      endpoint,
      data: <String, dynamic>{'uid': uid, 'taps': taps},
    );
  }
}
