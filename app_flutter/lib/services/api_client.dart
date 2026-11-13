import 'package:dio/dio.dart';

import 'auth_storage.dart';

Dio createDio({
  required String baseUrl,
  required AuthStorage storage,
  required void Function() onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final esLogin = error.requestOptions.path.contains('auth/login');
        if (error.response?.statusCode == 401 && !esLogin) {
          onUnauthorized();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}