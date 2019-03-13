import 'package:flutter/material.dart';
import 'search_result_view.dart';
import 'bucket_view.dart';
import 'event_bus.dart';
import 'click_effect.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'oss.dart';

class FileManagePage extends StatefulWidget {

  @override
  _FileManagePageState createState() => _FileManagePageState();
}

class _FileManagePageState extends State<FileManagePage> with AutomaticKeepAliveClientMixin {
    
    GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

    ScrollController controller = ScrollController();
    
    final _SearchDemoSearchDelegate _delegate = _SearchDemoSearchDelegate();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    int _lastIntegerSelected;

    String appTitle = '文件夹';
    String sDCardDir;
    List<double> position = [];
    List<File> files = [];
    
    @override
    bool get wantKeepAlive => true;
    
    _uploads() async {
        Map map = await Oss().upload();
        print(map);
        _easyRefreshKey.currentState.callRefresh();
    }

    Future<void> _refresh() async {
        files.clear();
        Map result = await Oss().bucket();
        for (var item in result['commonPrefixes']) {
            files.add(File(true,item['Prefix'],10,'png'));
        }
        for (var item in result['contents']) {
            files.add(File(false,item['Key'],0,'png'));
        }
        setState(() {});
    }

    Future<void> _more() async {
        return null;
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                leading: null == sDCardDir?null : IconButton(
                    icon: Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                    ),
                    onPressed: () {
                        if (null != sDCardDir) {
                            appTitle = '文件夹';
                            sDCardDir = null;
                            _refresh();
                            jumpToPosition(false);
                        }
                        else {
                            Navigator.pop(context);
                        }
                    }),
                title: Text(appTitle),
                actions: <Widget>[
                    IconButton(
                      tooltip: 'Search',
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                            final int selected = await showSearch<int>(
                                context: context,
                                delegate: _delegate,
                            );
                            if (selected != null && selected != _lastIntegerSelected) {
                                setState(() {
                                    _lastIntegerSelected = selected;
                                });
                            }
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.add),
                        tooltip: 'Upload Files',
                        onPressed: (){
                            _uploads();
                        }
                    ),
                    IconButton(
                        icon: Icon(
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Icons.more_horiz
                                : Icons.more_vert,
                        ),
                        tooltip: 'Show Bucket',
                        onPressed: (){
                            showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
                                return BucketView();
                            });
                        }
                    ),

                ],
            ),
            body: Scaffold(
                appBar: PreferredSize(
                    child: AppBar(
                        elevation: 0.4,
                        centerTitle: false,
                        backgroundColor: Color(0xffeeeeee),
                        title: Text(
                            'oss',
                            style: TextStyle(color: Colors.black),
                        ),
                    ),
                    preferredSize: Size.fromHeight(30)
                ),
                backgroundColor: Color(0xfff3f3f3),
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
                        child:ListView.builder(
                            controller: controller,
                            itemCount: files.length != 0 ? files.length : 1,
                            itemBuilder: (BuildContext context, int index) {
                                if (files.length != 0) {
                                    return buildListViewItem(files[index]);
                                }
                                else {
                                    return Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery
                                            .of(context).padding.top - 56.0),
                                        child: Center(
                                            child: Text('The folder is empty'),
                                        ),
                                    );
                                }
                            },
                        ),
                        onRefresh:() => _refresh(),
                        loadMore:() => _more(),
                    ),
                )
            ),//SearchResultView(),
        );
    }

    Widget buildListViewItem(File file) {
        return ClickEffect(
            child: Column(
                children: <Widget>[
                    ListTile(
                        leading: Image.asset(selectIcon(file)),
                        title: Row(
                            children: <Widget>[
                                Expanded(child: Text(file.name)),
                                file.isDir? Text('${file.num}项',style: TextStyle(color: Colors.grey)):Container()
                            ],
                        ),
                        subtitle: file.isDir? null:Text('11111111  132kb', style: TextStyle(fontSize: 12.0)),
                        trailing: file.isDir ? Icon(Icons.chevron_right):null,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Divider(height: 1.0),
                    )
                ],
            ),
            onTap: () {
                if (file.isDir) {
                    position.insert(position.length, controller.offset);
                    //initDirectory(file.path);
                    appTitle = sDCardDir = file.name;
                    print(sDCardDir);
                    _refresh();
                    jumpToPosition(true);
                }
                else {
                    //openFile(file.path);
                }
            
            },
        );
    }

    void jumpToPosition(bool isEnter) {
        if (isEnter) {
            controller.jumpTo(0.0);
        }
        else {
            controller.jumpTo(position[position.length - 1]);
            position.removeLast();
        }
    }
    
}

class _SearchDemoSearchDelegate extends SearchDelegate<int> {
  
  final List<int> _data = List<int>.generate(100001, (int i) => i).reversed.toList();
  final List<int> _history = <int>[42607, 85604, 66374, 44, 174];

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

    final Iterable<int> suggestions = query.isEmpty
        ? _history
        : _data.where((int i) => '$i'.startsWith(query));

    return _SuggestionList(
        query: query,
        suggestions: suggestions.map<String>((int i) => '$i').toList(),
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
                        text: suggestion.substring(0, query.length),
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

class File {
    File(this.isDir,this.name,this.num,this.ext);
    
    bool isDir;
    String name;
    int num;
    String ext;
}

selectIcon(File file) {
    try {
        String iconImg;
        if (file.isDir) {
            return 'assets/images/folder.png';
        }
        switch (file.ext) {
            case 'ppt':
            case 'pptx':
                iconImg = 'assets/images/ppt.png';
                break;
            case 'doc':
            case 'docx':
                iconImg = 'assets/images/word.png';
                break;
            case 'xls':
            case 'xlsx':
                iconImg = 'assets/images/excel.png';
                break;
            case 'jpg':
            case 'jpeg':
            case 'png':
                iconImg = 'assets/images/image.png';
                break;
            case 'txt':
                iconImg = 'assets/images/txt.png';
                break;
            case 'mp3':
                iconImg = 'assets/images/mp3.png';
                break;
            case 'mp4':
                iconImg = 'assets/images/video.png';
                break;
            case 'rar':
            case 'zip':
                iconImg = 'assets/images/zip.png';
                break;
            case 'psd':
                iconImg = 'assets/images/psd.png';
                break;
            default:
                iconImg = 'assets/images/file.png';
                break;
        }
        return iconImg;
    }
    catch (e) {
        return 'assets/images/unknown.png';
    }
}