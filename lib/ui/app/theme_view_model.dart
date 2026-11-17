import 'package:flutter/material.dart' show Brightness, ChangeNotifier, ThemeMode;

import '../../data/repositories/theme_repository.dart';

/// Light/dark mode: defaults to the OS, the header toggle overrides it and the
/// choice is remembered.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel(this._repository, {ThemeMode initialMode = ThemeMode.system})
      : _mode = initialMode;
  final ThemeRepository _repository;

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    _mode = await _repository.load();
    notifyListeners();
  }

  /// Switches away from the brightness currently on screen.
  Future<void> toggle(Brightness current) async {
    _mode = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _repository.save(_mode);
  }
}
