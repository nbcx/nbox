import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

/// 基本使用页面
class SearchResultView extends StatefulWidget {

    final String search;

    const SearchResultView({
        Key key,
        this.search: '明星'
    });
    
    @override
    _SearchResultViewState createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> with AutomaticKeepAliveClientMixin {
    
    GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
    bool _loadMore = true;

    int indexPage = 1;
    List<String> data = [];
    String search;

    @override
    void initState() {
        super.initState();
        //初始化状态
        search = widget.search;
        print("search $search");
    }

    @override
    bool get wantKeepAlive => true;
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
            child: new EasyRefresh(
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
                child:new GridView.builder(
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: data.length,
                    itemBuilder: buildImage,
                ),
              onRefresh: ()=>_onRefresh(),
              loadMore: ()=>_more(),
            )),
      );
    }

    Future<void> _more() async {
        print('_more');
        if(!_loadMore) {
            return null;
        }
        Dio dio = new Dio();
        Response response;

        response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=$search&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
        print(response.data.toString());
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
    
    Future<void> _onRefresh() async {
        print('_onRefresh');
        indexPage = 1;
        data.clear();
        Dio dio = new Dio();
        Response response;
        response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=$search&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
        print(response.data.toString());
        Map map = json.decode(response.data);
        var array = map["data"];
        for (var item in array) {
            data.add(item["image_url"]);
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