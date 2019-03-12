import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;
import 'meizi_list_item.dart';
import 'package:picbox/oss.dart';
import 'session.dart';

/// 基本使用页面
class HomePage extends StatefulWidget {
    
    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin { //with TickerProviderStateMixin
    
    GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
    bool _loadMore = true;

    int indexPage = 1;
    List<String> data = [];

    String tips;

    @override
    bool get wantKeepAlive => true;
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
            title: Text('图片盒子'),
            actions: <Widget>[
                new PopupMenuButton(
                    icon:const Icon(Icons.add),
                    onSelected: (String value){
                        print("onSelected $value");
                        Oss().upload();
                    },
                    itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
                        new PopupMenuItem(
                            value:"选项一的内容",
                            child: new Text("选项一")
                        ),
                        new PopupMenuItem(
                            value: "选项二的内容",
                            child: new Text("选项二")
                        )
                    ]
                ),
            ]
        ),
        body: Center(
            child: EasyRefresh(
                key: _easyRefreshKey,
                firstRefresh: true,
                behavior: ScrollOverBehavior(),
                refreshHeader: ClassicsHeader(
                    key: _headerKey,
                    refreshText: '下拉刷新',
                    refreshReadyText: '释放加载',
                    refreshingText: "正在刷新...",
                    refreshedText: "刷新结束",
                    moreInfo: "更新于 %T",
                    bgColor: Colors.transparent,
                    textColor: Colors.black87,
                    moreInfoColor: Colors.black54,
                    showMore: true,
                ),
                refreshFooter: ClassicsFooter(
                    key: _footerKey,
                    loadText: "上拉加载",
                    loadReadyText: "释放加载",
                    loadingText: "正在加载",
                    loadedText: "加载结束",
                    noMoreText: "没有更多数据",
                    moreInfo: "更新于 %T",
                    bgColor: Colors.transparent,
                    textColor: Colors.black87,
                    moreInfoColor: Colors.black54,
                    showMore: true,
                ),
                emptyWidget: _tips(),
                child: ListView.builder(
                    //ListView的Item
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                        return Container(
                            height: 360,
                            child: MeiZiListItem(data[index], currentIndex: index)
                        );
                    }
                ),
                onRefresh: ()=>_onRefresh(),
                loadMore: ()=>_more(),
            )),
      );
    }

    Widget _tips() {
        if(tips == null) {
            return null;
        }
        return Container(
            padding: EdgeInsets.all(20.0),
            width: double.infinity,
            height: 500.0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Icon(Icons.inbox,size: 50.0,color: Colors.grey),
                    Text(tips,style: TextStyle(fontSize: 18.0, color: Colors.grey))
                ],
            ),
        );
    }

    Future<void> _onRefresh() async{
        indexPage = 1;
        data.clear();
        Map tmp = await Oss().bucket();
        if(tmp['code'] != 0) {
            tips = tmp['message'];
            return null;
        }
        List _list = tmp['contents'];
        String domain = Session.getString('_domain');
        for (var item in _list) {
            print("https://$domain/${item['Key']}?x-oss-process=image/resize,h_360");
            data.add("https://$domain/${item['Key']}?x-oss-process=image/resize,h_360");
        }
        indexPage++;
        setState(() {
            _easyRefreshKey.currentState.waitState(() {
                setState(() {
                    _loadMore = true;
                });
            });
        });
    }

    Future<void> _more() async {
        print('_more');
        if(!_loadMore) {
            return null;
        }
        Dio dio = new Dio();
        Response response;
        response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=%E6%98%8E%E6%98%9F&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
        Map map = json.decode(response.data);
        List array = map["data"];
        if(array.length < 1) {
            _easyRefreshKey.currentState.waitState(() {
                setState(() {
                    _loadMore = false;
                });
            });
        }
        else {
            for (var item in array) {
                data.add(item["image_url"]);
            }
            indexPage++;
            setState(() {});
        }
    }
    
    Future<void> _onRefresh_bak() async {
        print('_onRefresh');
        indexPage = 1;
        data.clear();
        Dio dio = new Dio();
        Response response;
        response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=美女&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
        Map map = json.decode(response.data);
        var array = map["data"];
        for (var item in array) {
            data.add(item["image_url"]);
        }
        indexPage++;
        setState(() {
            //str.clear();
            //str.addAll(addStr);
            _easyRefreshKey.currentState.waitState(() {
                setState(() {
                    _loadMore = true;
                });
            });
        });
    }

    Widget buildImage(context, index) {
        return new Item(
            url: data[index],
        );
    }
}

class Item extends StatefulWidget {
    final String url;
    
    Item({this.url});
    
    @override
    _ItemState createState() => new _ItemState();
}

class _ItemState extends State<Item> {
    @override
    Widget build(BuildContext context) {
        if (widget.url == null) return new Container();
        return new RepaintBoundary(
            child: new Image.network(
                widget.url,
                fit: BoxFit.cover,
            ),
        );
    }

    @override
    void dispose() {
        // TODO: implement dispose
        super.dispose();
    }
}