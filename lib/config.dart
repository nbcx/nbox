import 'package:flutter/material.dart';
import 'sqlite.dart';

class Config {

    //私有构造函数
    Config._internal();

    //保存单例
    static Config _singleton = new Config._internal();

    //工厂构造函数
    factory Config()=> _singleton;

    Map k = Map();

    final List<String> supportedLanguages = ['en', 'zh'];

    Future<void> init() async {
        List conf = await db.gets("SELECT * FROM config");

        for (var item in conf) {
            k[item['name']] = item['value'];
        }
        k['lang'] = 'en';
    }

    Iterable<Locale> supportedLocales() => supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));

    Future<int> updateThemeColor(String color) async {
        k['theme_color'] = color;
        return db.update('UPDATE config SET value = ? WHERE name = ?',[color,'theme_color']);
    }

    Future<int> updateLanguage(String lang) async {
        k['lang'] = lang;
        return db.update('UPDATE config SET value = ? WHERE name = ?',[lang,'lang']);
    }

}
var conf = new Config();