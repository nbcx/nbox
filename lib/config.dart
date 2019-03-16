import 'sqlite.dart';

class Config {

    //私有构造函数
    Config._internal();

    //保存单例
    static Config _singleton = new Config._internal();

    //工厂构造函数
    factory Config()=> _singleton;

    Map k = Map();

    Future<void> init() async {
        List conf = await db.gets("SELECT * FROM config");

        for (var item in conf) {
            k[item['name']] = item['value'];
        }
    }

    Future<int> updateThemeColor(String color) async {
        k['theme_color'] = color;
        return db.update('UPDATE config SET value = ? WHERE name = ?',[color,'theme_color']);
    }

}
var conf = new Config();