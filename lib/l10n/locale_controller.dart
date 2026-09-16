import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drži izabrani jezik i pamti ga na uređaju.
/// null = prati jezik telefona; inače je izabran ručno (en ili sr).
class LocaleController extends ChangeNotifier {
  static const _key = 'locale_code';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) _locale = Locale(code);
    notifyListeners();
  }

  Future<void> select(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final LocaleController localeController = LocaleController();
