import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

class SearchControllerDelegate extends SearchDelegate<int> {

    final List<String> _data = ['hello'];
    final List<String> _history = <String>['美女', '明星', '动物', '卡通'];

    @override
    Widget buildLeading(BuildContext context) {
        return IconButton(
            tooltip: 'Back',
            icon: AnimatedIcon(
                icon: AnimatedIcons.menu_arrow,
                progress: transitionAnimation,
            ),
            onPressed: () {
                close(context, null);
            },
        );
    }

    @override
    Widget buildSuggestions(BuildContext context) {

        //final Iterable<int> suggestions = query.isEmpty ? _history : _data.where((String i) => '$i'.startsWith(query));

        return _SuggestionList(
            query: query,
            suggestions: _history,
            onSelected: (String suggestion) {
                query = suggestion;
                showResults(context);
            },
        );
    }

    @override
    Widget buildResults(BuildContext context) {
        if (query == null) {
            return Center(
                child: Text('"$query"\n is not a valid integer between 0 and 100,000.\nTry again.',
                    textAlign: TextAlign.center,
                ),
            );
        }
        return SearchResultView();//search: query
    }

    @override
    List<Widget> buildActions(BuildContext context) {
        return <Widget>[
            query.isEmpty
                ? IconButton(
                tooltip: 'Voice Search',
                icon: const Icon(Icons.mic),
                onPressed: () {
                    query = 'TODO: implement voice input';
                },
            )
                : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear),
                onPressed: () {
                    query = '';
                    showSuggestions(context);
                },
            ),
        ];
    }
}

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
                child:GridView.builder(
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



class _SuggestionList extends StatelessWidget {
    const _SuggestionList({this.suggestions, this.query, this.onSelected});

    final List<String> suggestions;
    final String query;
    final ValueChanged<String> onSelected;

    @override
    Widget build(BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int i) {
                final String suggestion = suggestions[i];
                return ListTile(
                    leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
                    title: RichText(
                        text: TextSpan(
                            text:query,
                            style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                                TextSpan(
                                    text: suggestion.substring(query.length),
                                    style: theme.textTheme.subhead,
                                ),
                            ],
                        ),
                    ),
                    onTap: () {
                        onSelected(suggestion);
                    },
                );
            },
        );
    }
}