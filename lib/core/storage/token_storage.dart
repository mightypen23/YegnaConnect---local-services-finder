import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html show window;

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage[_tokenKey] = token;
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> readToken() async {
    if (kIsWeb) {
      return html.window.localStorage[_tokenKey];
    } else {
      return await _storage.read(key: _tokenKey);
    }
  }

  Future<void> clearToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }
}
