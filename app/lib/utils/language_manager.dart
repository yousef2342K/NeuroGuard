import 'package:flutter/material.dart';

class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  final ValueNotifier<Locale> currentLocale = ValueNotifier(const Locale('ar', 'EG'));
  
  static const Locale arabicLocale = Locale('ar', 'EG');
  static const Locale englishLocale = Locale('en', 'US');
  
  static const List<Locale> supportedLocales = [arabicLocale, englishLocale];
  
  bool get isArabic => currentLocale.value.languageCode == 'ar';
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  
  void setLanguage(Locale locale) {
    currentLocale.value = locale;
  }
  
  void toggleLanguage() {
    if (isArabic) {
      setLanguage(englishLocale);
    } else {
      setLanguage(arabicLocale);
    }
  }
  
  String getLanguageName() {
    return isArabic ? 'العربية' : 'English';
  }
  
  String getLanguageCode() {
    return currentLocale.value.languageCode;
  }
}
