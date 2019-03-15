import 'package:flutter/material.dart';
import 'colors.dart';
import 'session.dart';
import 'sqlite.dart';
import 'file_manage_page.dart';
import 'cloud_setting_page.dart';
import 'oss.dart';

void main() async {
  setCustomErrorPage();
  await db.init();
  await Session.getInstance();
  await Oss().init();
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  
    @override
    _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
    Color _themeColor = Colors.black;

    @override
    void initState() {
        super.initState();
        _initAsync();
    }

    void _initAsync() async {
        String _colorKey = Session.getString('key_theme_color');
        if (themeColorMap[_colorKey] != null)
            _themeColor = themeColorMap[_colorKey];
    }

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: '图片盒子',
            theme: ThemeData(//.light().copyWith
                primaryColor: _themeColor,
                accentColor: _themeColor,
                indicatorColor: Colors.white,
            ),

            home: Oss().have?FileManagePage():CloudSettingPage(first: true),
        );
    }

}

void setCustomErrorPage(){
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails){
        //print(flutterErrorDetails.toString());
        return Center(
            child: Text("我好像错了！"),
        );
    };
}