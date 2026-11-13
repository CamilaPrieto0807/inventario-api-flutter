import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _secure = FlutterSecureStorage();
  static const _kToken = 'access_token';
  static const _kNombre = 'user_nombre';
  static const _kEmail = 'user_email';

  Future<void> saveSession({
    required String token,
    required String nombre,
    required String email,
  }) async {
    await _secure.write(key: _kToken, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNombre, nombre);
    await prefs.setString(_kEmail, email);
  }

  Future<String?> readToken() => _secure.read(key: _kToken);

  Future<({String? nombre, String? email})> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    return (nombre: prefs.getString(_kNombre), email: prefs.getString(_kEmail));
  }

  Future<void> clear() async {
    await _secure.delete(key: _kToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kNombre);
    await prefs.remove(_kEmail);
  }
}