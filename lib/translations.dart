import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';

class Translations {
    
    Locale locale;
    static Map<dynamic, dynamic> _localizedValues;
    
    Translations(Locale locale) {
      this.locale = locale;
    }

    static Translations of(BuildContext context) {
        return Localizations.of<Translations>(context, Translations);
    }

    static t(String key) {
        if (_localizedValues == null) {
            return key;
        }
        return _localizedValues[key] ?? key;
    }
    
    String text(String key) {
        if (_localizedValues == null) {
          return key;
        }
        return _localizedValues[key] ?? key;
    }

    static Future<Translations> load(Locale locale) async {
        Translations translations = Translations(locale);
        String languageCode = conf.supportedLanguages.contains(locale.languageCode) ? locale.languageCode : "en";
        String jsonContent = await rootBundle.loadString("locale/i18n_$languageCode.json");
        _localizedValues = json.decode(jsonContent);
        return translations;
    }

    get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
    const TranslationsDelegate();

    @override
    bool isSupported(Locale locale) => conf.supportedLanguages.contains(locale.languageCode);

    @override
    Future<Translations> load(Locale locale) => Translations.load(locale);

    @override
    bool shouldReload(TranslationsDelegate old) => false;
}

class SpecificLocalizationDelegate extends LocalizationsDelegate<Translations> {
    final Locale overriddenLocale;

    const SpecificLocalizationDelegate(this.overriddenLocale);

    @override
    bool isSupported(Locale locale) => overriddenLocale != null;

    @override
    Future<Translations> load(Locale locale) => Translations.load(overriddenLocale);

    @override
    bool shouldReload(LocalizationsDelegate<Translations> old) => true;
}
