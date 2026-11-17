import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error from the backend. [message] is the server's `statusMessage`, if any.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String? message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): ${message ?? 'request failed'}';
}

/// Thin JSON-over-HTTP client for the same-origin `/api/*` endpoints.
///
/// For local development against another host:
/// `flutter run -d chrome --dart-define=API_BASE=http://localhost:8787`
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE');

  final http.Client _http;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 30);

  Uri _uri(String path) =>
      _baseUrl.isEmpty ? Uri.base.resolve(path) : Uri.parse(_baseUrl).resolve(path);

  /// POSTs [body] as JSON and returns the decoded JSON object.
  /// Throws [ApiException] on non-2xx responses or malformed bodies.
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final http.Response res;
    try {
      res = await _http
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw ApiException(null);
    } catch (_) {
      throw ApiException(null);
    }

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = data?['statusMessage'] ?? data?['message'];
      throw ApiException(
        msg is String && msg.trim().isNotEmpty ? msg : null,
        statusCode: res.statusCode,
      );
    }
    if (data == null) throw ApiException(null, statusCode: res.statusCode);
    return data;
  }
}
