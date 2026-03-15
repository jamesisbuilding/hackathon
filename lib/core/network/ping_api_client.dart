import 'package:dio/dio.dart';

class PingApiClient {
  PingApiClient({required this.endpoint, Dio? dio})
      : _dio = dio ??
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

  Future<void> sendScrollDownPing({
    required DateTime timestamp,
    required double scrollY,
  }) async {
    await _dio.post<void>(
      endpoint,
      data: <String, dynamic>{
        'event': 'thumb_down',
        'direction': 'down',
        'timestamp': timestamp.toUtc().toIso8601String(),
        'scrollY': scrollY,
      },
    );
  }
}
