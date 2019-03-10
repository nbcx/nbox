import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class Sqlite {

    Database database;

    //私有构造函数
    Sqlite._internal();

    //保存单例
    static Sqlite _singleton = new Sqlite._internal();

    //工厂构造函数
    factory Sqlite()=> _singleton;

    //初始化数据库
    Future init() async {
        print('_initdb');

        //Get a location using getDatabasesPath
        String databasesPath = await getDatabasesPath();
        String path = join(databasesPath, 'flutter.db');
        print(path);
        try {
            database = await openDatabase(path);
        }
        catch (e) {
            print("Error $e");
        }
        bool tableIsRight = await this.checkTableIsRight();

        if (!tableIsRight) {
            // 关闭上面打开的db，否则无法执行open
            database.close();
            // Delete the database
            await deleteDatabase(path);
            ByteData data = await rootBundle.load(join("assets", "app.db"));
            List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await new File(path).writeAsBytes(bytes);

            database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
                print('db created version is $version');
            }, onOpen: (Database db) async {
                print('new db opened');
            });
        }
        else {
            print("Opening existing database");
        }
        print('_initdb end');
    }

    // 检查数据库中, 表是否完整, 在部份android中, 会出现表丢失的情况
    Future checkTableIsRight() async {
        List<String> expectTables = ['cat', 'widget', 'cloud'];

        List<String> tables = await getTables();

        for(int i = 0; i < expectTables.length; i++) {
            if (!tables.contains(expectTables[i])) {
                return false;
            }
        }
        return true;
    }

    // 获取数据库中所有的表
    Future<List> getTables() async {
        if (database == null) {
            return Future.value([]);
        }
        List tables = await database.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');

        print(tables);
        List<String> targetList = [];
        tables.forEach((item)  {
            targetList.add(item['name']);
        });
        return targetList;
    }

    close() async{
        // 关闭数据库
        await database.close();
    }

    Future<void> drop(String path) async{
        // 删除数据库
        await deleteDatabase(path);
    }

    Future<List<Map<String, dynamic>>> query(String sql,[List<dynamic> arguments]) async{
        return await database.rawQuery(sql,arguments);
    }

    //获取单条记录
    Future<Map<String, dynamic>> get(String sql,[List<dynamic> arguments]) async {
        List<Map> data;
        if(arguments == null) {
            data = await database.rawQuery(sql);
        }
        else {
            data = await database.rawQuery(sql,arguments);
        }
        return data[0];
    }

    //获取多条记录
    Future<List<Map<String, dynamic>>> gets(String sql,[List<dynamic> arguments]) async{
        // 获取Test表的数据
        List<Map> data = await database.rawQuery(sql, arguments);
        //List<Map> expectedList = [
        //    {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
        //    {"name": "another name", "id": 2, "value": 12345678, "num": 3.1416}
        //];
        //print(data);
        //print(expectedList);
        //assert(const DeepCollectionEquality().equals(list, expectedList));
        return data;
    }

    Future<int> count() async{
        // 获取记录的数量
        int count = Sqflite.firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM cat"));
        print(count);
        return count;
    }

    Future<int> update() async {
        // 更新一条记录
        int count = await database.rawUpdate(
            'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
            ["updated name", "9876", "some name"]
        );
        print("updated: $count");
        return count;
    }

    Future<T> transaction<T>(Future<T> action(Transaction txn), {bool exclusive}) {
        database.transaction(action,exclusive:exclusive);
    }

    transactions(Function callback) async {
        await database.transaction((txn) async {
            int id1 = await txn.rawInsert(
                'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
            print("inserted1: $id1");
            int id2 = await txn.rawInsert(
                'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
                ["another name", 12345678, 3.1416]);
            print("inserted2: $id2");
        });
    }

    /// Returns the last inserted record id
    Future<int> add(String sql, [List<dynamic> arguments]) async{
        return await database.rawInsert(sql,arguments);
    }

    // INSERT helper
    Future<int> insert(String table, Map<String, dynamic> values,
        {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    }

    Future<int> del() async {
        // 删除一条记录
        int count = await database.rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
        return count;
    }
}

var db = new Sqlite();