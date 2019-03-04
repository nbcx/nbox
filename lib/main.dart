import 'package:flutter/material.dart';
import 'navigation_page.dart';
import 'event_bus.dart';

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
  
  Color _themeColor = Colors.deepPurple;
  
  @override
  void initState() {
      super.initState();
      bus.on("tabchange", (arg) {
          setState(() {
              _themeColor = arg;
          });
      });
  }
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        title: '图片盒子',
        theme: ThemeData(
            primarySwatch: _themeColor,
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