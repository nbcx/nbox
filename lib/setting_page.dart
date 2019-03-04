import 'package:flutter/material.dart';
import 'package:picbox/colors.dart';
import 'package:picbox/setting_app_page.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /**/
    //final MainBloc bloc = BlocProvider.of<MainBloc>(context);
    ComModel github = new ComModel(
        title: 'GitHub',
        url: 'https://github.com/Sky24n/flutter_wanandroid',
        extra: 'Go Star'
    );
    ComModel author = new ComModel(title: '作者', page: SettingAppPage());
    ComModel other = new ComModel(title: '设置', page: SettingAppPage());

    return new Scaffold(
      appBar: new AppBar(
          title: new Text('设置'),
          centerTitle: true,
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
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
          new ComArrowItem(other),
          new ComArrowItem(github),
          new ComArrowItem(author),
          new StreamBuilder(
              //stream: bloc.versionStream,
              builder:(BuildContext context, AsyncSnapshot snapshot) {
                //VersionModel model = snapshot.data;
                return new Container(
                  child: new Material(
                    color: Colors.white,
                    child: new ListTile(
                      onTap: () {

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


class ComArrowItem extends StatelessWidget {

  const ComArrowItem(this.model, {Key key}) : super(key: key);
  final ComModel model;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Material(
        color: Colors.white,
        child: new ListTile(
          onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => model.page));
          },
          title: new Text(model.title == null ? "" : model.title),
          trailing: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(
                model.extra == null ? "" : model.extra,
                style: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              new Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      decoration: Decorations.bottom,
    );
  }
}

class Decorations {
  static Decoration bottom = BoxDecoration(
      border: Border(bottom: BorderSide(width: 0.33, color: Colours.divider)));
}

class ComModel {
  String version;
  String title;
  String content;
  String extra;
  String url;
  String imgUrl;
  String author;
  String updatedAt;

  int typeId;
  String titleId;

  Widget page;

  ComModel(
      {this.version,
        this.title,
        this.content,
        this.extra,
        this.url,
        this.imgUrl,
        this.author,
        this.updatedAt,
        this.typeId,
        this.titleId,
        this.page});

  ComModel.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        title = json['title'],
        content = json['content'],
        extra = json['extra'],
        url = json['url'],
        imgUrl = json['imgUrl'],
        author = json['author'],
        updatedAt = json['updatedAt'];

  Map<String, dynamic> toJson() => {
    'version': version,
    'title': title,
    'content': content,
    'extra': extra,
    'url': url,
    'imgUrl': imgUrl,
    'author': author,
    'updatedAt': updatedAt,
  };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"version\":\"$version\"");
    sb.write(",\"title\":\"$title\"");
    sb.write(",\"content\":\"$content\"");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"imgUrl\":\"$imgUrl\"");
    sb.write(",\"author\":\"$author\"");
    sb.write(",\"updatedAt\":\"$updatedAt\"");
    sb.write('}');
    return sb.toString();
  }
}