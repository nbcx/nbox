import 'package:flutter/material.dart';
import 'navigation_page.dart';
import 'event_bus.dart';
import 'colors.dart';
import 'session.dart';

void main() async {
  setCustomErrorPage();
  //final provider = new Provider();
  //await provider.init(true);
  
  return runApp(MyApp());
  
  //return runApp(MyApp());
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
      await Session.getInstance();
    
      String _colorKey = Session.getString('key_theme_color');
      if (themeColorMap[_colorKey] != null)
          _themeColor = themeColorMap[_colorKey];
    
      bus.on("themechange", (arg) {
          print(arg);
          setState(() {
              _themeColor = themeColorMap[arg];
          });
      });
  }
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        title: '图片盒子',
        theme: ThemeData.light().copyWith(
            primaryColor: _themeColor,
            accentColor: _themeColor,
            indicatorColor: Colors.white,
        ),
        home: NavigationPage(),
    );
  }
  
}

void setCustomErrorPage(){
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails){
        //print(flutterErrorDetails.toString());
        return Center(
            child: Text("Flutter 走神了"),
        );
  };
}