import 'package:flutter/material.dart';
import 'package:my_web_app/genetated/app_localizations.dart'; // Обновите путь к файлу локализаций

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = Locale('en');
    notifyListeners();
  }
}
