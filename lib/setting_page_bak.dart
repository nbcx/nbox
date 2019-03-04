import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:picbox/setting_app_page.dart';

/// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with AutomaticKeepAliveClientMixin {

  Widget _line() {
      return Container(
          width: double.infinity,
          height: 0.5,
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          child: Container(
            color: Colors.black12,
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('我'),
      ),
      body: EasyRefresh(
        behavior: ScrollOverBehavior(),
        child: ListView(
          children: <Widget>[
            ListItem(
              title: '个人中心',
              describe: '先想想想想想想想想想想想想想想想想',
              icon: Icon(
                Icons.person,
                color: Colors.orange,
              ),
              onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                    //return UserProfilePage();
                  }));
              },
            ),
            _line(),
            ListItem(
              title: '个人中心2',
              describe: 'ddd',
              icon: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.orange,
              ),
              onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                      //return ContactsDemo();
                  }));
              },
            ),
            _line(),
            ListItem(
              title: '设置',
              describe: "APP个性设置",
              icon: Icon(
                Icons.http,
                color: Colors.orange,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return SettingAppPage();
                    })
                );
              },
            ),
            _line(),
            ListItem(
              title: '关于',
              icon: Icon(
                Icons.info,
                color: Colors.orange,
              ),
              onPressed: () {
                //launch("https://nb.cx");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}


/// 列表项
class ListItem extends StatefulWidget {
  // 点击事件
  final VoidCallback onPressed;
  // 图标
  final Widget icon;
  // 标题
  final String title;
  final Color titleColor;
  // 描述
  final String describe;
  final Color describeColor;
  // 右侧控件
  final Widget rightWidget;
  
  // 构造函数
  ListItem({
    Key key,
    this.onPressed,
    this.icon,
    this.title,
    this.titleColor: Colors.black,
    this.describe,
    this.describeColor: Colors.grey,
    this.rightWidget,
  }) : super(key: key);
  
  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onPressed,
      padding: EdgeInsets.all(0.0),
      shape: Border.all(
        color: Colors.transparent,
        width: 0.0,
        style: BorderStyle.none,
      ),
      child: Container(
          height: 60.0,
          width: double.infinity,
          child: Row(
            children: <Widget>[
              widget.icon != null
                  ? Container(
                padding: EdgeInsets.all(14.0),
                child: SizedBox(
                  height: 32.0,
                  width: 32.0,
                  child: widget.icon,
                ),
              )
                  : Container(
                width: 14.0,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.title != null
                        ? Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.titleColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : Container(),
                    widget.describe != null
                        ? Text(
                      widget.describe,
                      maxLines: 2,
                      style: TextStyle(
                          color: widget.describeColor, fontSize: 12.0),
                    )
                        : Container(),
                  ],
                ),
              ),
              widget.rightWidget == null ? Container() : widget.rightWidget,
              Container(
                width: 14.0,
              ),
            ],
          )),
    );
  }
}

/// 空图标
class EmptyIcon extends Icon {
  EmptyIcon() : super(Icons.hourglass_empty);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}