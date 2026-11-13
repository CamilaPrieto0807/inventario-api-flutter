import 'package:dio/dio.dart';

import 'product_api.dart' show ApiException;

class AuthSession {
  const AuthSession({
    required this.token,
    required this.nombre,
    required this.email,
  });

  final String token;
  final String nombre;
  final String email;
}

class SessionInvalidException implements Exception {
  const SessionInvalidException();
}

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      return AuthSession(
        token: data['access_token'] as String,
        nombre: user['nombre'] as String,
        email: user['email'] as String,
      );
    } on DioException catch (error) {
      throw ApiException(_mensaje(error));
    }
  }

  /// Valida el token guardado contra el backend.
  Future<({String nombre, String email})> me() async {
    try {
      final response = await _dio.get('auth/me');
      final data = response.data as Map<String, dynamic>;
      return (nombre: data['nombre'] as String, email: data['email'] as String);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) throw const SessionInvalidException();
      throw ApiException(_mensaje(error));
    }
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.response == null) {
      return 'No se pudo conectar con el servidor. Verifica que esté activo.';
    }
    return 'Error HTTP ${error.response?.statusCode ?? ''}';
  }
}