import 'package:flutter/material.dart' show ThemeMode;

import '../services/preferences_service.dart';

/// Persists the light/dark choice (key `theme`, values `light` / `dark`).
class ThemeRepository {
  ThemeRepository(this._prefs);
  final PreferencesService _prefs;

  static const _key = 'theme';

  Future<ThemeMode> load() async {
    return switch (await _prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> save(ThemeMode mode) async {
    if (mode == ThemeMode.system) return;
    await _prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
