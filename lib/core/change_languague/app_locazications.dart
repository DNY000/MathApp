import 'package:flutter/widgets.dart';
import 'package:math_app/core/shared_preferences/shared_prefs.dart';

class AppLocazications {
  static Locale? _localeFromCode(String? code) {
    if (code == null) return null;
    final parts = code.split('-');
    if (parts.length != 2) return null;
    return Locale(parts[0], parts[1]);
  }

  static final savedLocaleCode = SharedPrefs.instance.get<String>(
    'app_language',
  );
  static final Locale startLocale =
      _localeFromCode(savedLocaleCode) ?? const Locale('vi', 'VN');
  static const Locale engLocale = Locale('en', 'US');
  static const Locale viLocale = Locale('vi', 'VN');
  static const String translationFile = 'assets/translations';
}
