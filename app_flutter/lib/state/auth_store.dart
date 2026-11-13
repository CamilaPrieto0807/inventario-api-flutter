import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/auth_api.dart';
import '../services/auth_storage.dart';
import '../services/product_api.dart' show ApiException;

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthStore extends ChangeNotifier {
  AuthStore(this._api, this._storage);

  final AuthApi _api;
  final AuthStorage _storage;

  AuthStatus status = AuthStatus.unknown;
  bool isLoading = false;
  String? errorMessage;
  String? nombre;
  String? email;
  String? tokenPreview; // solo los últimos 4 caracteres

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasToken => tokenPreview != null;

  String _mask(String token) =>
      token.length > 4 ? '••••${token.substring(token.length - 4)}' : '••••';

  /// Se ejecuta al abrir la app: recupera y valida la sesión guardada.
  Future<void> init() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final saved = await _storage.readUser();
    nombre = saved.nombre;
    email = saved.email;
    tokenPreview = _mask(token);
    try {
      final me = await _api.me();
      nombre = me.nombre;
      email = me.email;
      status = AuthStatus.authenticated;
    } on SessionInvalidException {
      await _clearSession(message: 'Tu sesión expiró. Inicia sesión de nuevo.');
      return;
    } on ApiException {
      // Sin conexión: se conserva la sesión; las peticiones mostrarán su error.
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await _api.login(email.trim(), password);
      await _storage.saveSession(
        token: session.token,
        nombre: session.nombre,
        email: session.email,
      );
      nombre = session.nombre;
      this.email = session.email;
      tokenPreview = _mask(session.token);
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _clearSession();

  /// Lo llama el interceptor de Dio cuando la API responde 401.
  void sessionExpired() {
    if (status == AuthStatus.unauthenticated) return;
    unawaited(
      _clearSession(message: 'Tu sesión expiró. Inicia sesión de nuevo.'),
    );
  }

  Future<void> _clearSession({String? message}) async {
    await _storage.clear();
    nombre = null;
    email = null;
    tokenPreview = null;
    errorMessage = message;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}