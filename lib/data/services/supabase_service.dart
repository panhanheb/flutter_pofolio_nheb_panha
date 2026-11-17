import 'dart:convert';

import 'package:http/http.dart' as http;

/// Supabase connection settings, set at build time:
///
///   `flutter run -d chrome --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY`
///
/// Only the public **anon** key belongs here. It can read the public tables
/// (projects, blog_posts) and nothing else, enforced by RLS in
/// supabase/schema.sql. The service-role key must never be compiled into the app.
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  factory SupabaseConfig.fromEnvironment() => const SupabaseConfig(
        url: String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://wyuxriiwljkcfqayrvpd.supabase.co',
        ),
        anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  final String url;
  final String anonKey;

  bool get isConfigured => url.startsWith('https://') && anonKey.isNotEmpty;
}

class SupabaseException implements Exception {
  SupabaseException(this.message);
  final String message;
  @override
  String toString() => 'SupabaseException: $message';
}

/// Minimal read-only client for Supabase's REST API (PostgREST).
class SupabaseService {
  SupabaseService(this.config, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final SupabaseConfig config;
  final http.Client _http;

  static const _timeout = Duration(seconds: 10);

  /// `GET /rest/v1/TABLE?select=...&order=...` → list of rows.
  /// Throws [SupabaseException] if not configured or the request fails.
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String select = '*',
    String? order,
  }) async {
    if (!config.isConfigured) throw SupabaseException('not configured');
    final uri = Uri.parse('${config.url.replaceAll(RegExp(r'/+$'), '')}/rest/v1/$table')
        .replace(queryParameters: {
      'select': select,
      'order': ?order,
    });
    final res = await _http.get(uri, headers: {
      'apikey': config.anonKey,
      'Authorization': 'Bearer ${config.anonKey}',
      'Accept': 'application/json',
    }).timeout(_timeout);
    if (res.statusCode != 200) {
      throw SupabaseException('GET $table → ${res.statusCode}');
    }
    final body = jsonDecode(res.body);
    if (body is! List) throw SupabaseException('unexpected response for $table');
    return body.whereType<Map<String, dynamic>>().toList();
  }
}
