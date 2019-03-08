import 'package:flutter/material.dart';
import 'package:picbox/colors.dart';
import 'package:picbox/setting_app_page.dart';
import 'package:picbox/oss.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
          title: new Text('设置'),
      ),
      body: new ListView(
        children: <Widget>[
          Container(
              height: 160.0,
              alignment: Alignment.center,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Card(
                    color: Theme.of(context).primaryColor,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                    child: new Image.asset(
                        'assets/images/ali_connors.png',
                        width: 72.0,
                        fit: BoxFit.fill,
                        height: 72.0,
                    ),
                  ),
                  new SizedBox(height: 5),
                  new Text(
                    '图片盒子',
                    style: new TextStyle(color: Colours.gray_99, fontSize: 14.0),
                  )
                ],
              ),
              decoration: new BoxDecoration(
                  color: Colors.white,
                  border: new Border.all(width: 0.33, color: Colours.divider)
              )
          ),
          StreamBuilder(
            //stream: bloc.versionStream,
              builder:(BuildContext context, AsyncSnapshot snapshot) {
                  //VersionModel model = snapshot.data;
                  return new Container(
                    child: new Material(
                      color: Colors.white,
                      child: new ListTile(
                        onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingAppPage()));
                        },
                        title: new Text('设置'),
                        //dense: true,
                        trailing: new Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Icon(
                              Icons.navigate_next,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //decoration: Decorations.bottom,
                  );
              }
          ),
          StreamBuilder(
            //stream: bloc.versionStream,
              builder:(BuildContext context, AsyncSnapshot snapshot) {
                //VersionModel model = snapshot.data;
                return new Container(
                  child: new Material(
                    color: Colors.white,
                    child: new ListTile(
                      onTap: () {
                      },
                      title: new Text('GitHub'),
                      //dense: true,
                      trailing: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text('Go Star',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0
                            ),
                          ),
                          new Icon(
                            Icons.navigate_next,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //decoration: Decorations.bottom,
                );
              }),
          StreamBuilder(
            //stream: bloc.versionStream,
              builder:(BuildContext context, AsyncSnapshot snapshot) {
                //VersionModel model = snapshot.data;
                return new Container(
                  child: new Material(
                    color: Colors.white,
                    child: new ListTile(
                      onTap: () {
                      },
                      title: new Text('作者'),
                      //dense: true,
                      trailing: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Icon(
                            Icons.navigate_next,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //decoration: Decorations.bottom,
                );
              }),
          StreamBuilder(
              //stream: bloc.versionStream,
              builder:(BuildContext context, AsyncSnapshot snapshot) {
                //VersionModel model = snapshot.data;
                return new Container(
                  child: new Material(
                    color: Colors.white,
                    child: new ListTile(
                      onTap: () {
                        //Oss().test();
                        //Oss().upload();
                        Oss().list();
                      },
                      title: new Text('版本更新'),
                      //dense: true,
                      trailing: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text('已是最新版',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0
                            ),
                          ),
                          new Icon(
                            Icons.navigate_next,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //decoration: Decorations.bottom,
                );
              }),
          //new ComArrowItem(other),
        ],
      ),
    );
  }
}
