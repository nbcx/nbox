import 'package:flutter/material.dart';
import 'search_result_view.dart';
import 'bucket_view.dart';
import 'click_effect.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'oss.dart';
import 'drawer_view.dart';
import 'package:path/path.dart' as path;
import 'photo_gallery_page.dart';

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

    Oss oss = new Oss();
    String prefix,marker;
    List<double> position = [];
    List<File> files = [];
    List<String> prefixS = [];
    
    @override
    bool get wantKeepAlive => true;

    //@override
    //void initState() {
    //    super.initState();
    //    print("prefixS "+prefixS.join('/'));
    //}

    IconData _backIcon() {
        if(Theme.of(context).platform == TargetPlatform.iOS) {
            return Icons.arrow_back_ios;
        }
        else {
            return Icons.arrow_back;
        }
    }
    
    _uploads() async {
        Map map = await oss.upload();
        print(map);
        _easyRefreshKey.currentState.callRefresh();
    }

    _pull({String prefix,bool clear=true,String delimiter='/',int maxKeys=100,String marker}) async {
        Map result = await oss.bucket(prefix:prefix,delimiter:delimiter,maxKeys:maxKeys,marker:marker);
        if(clear) files.clear();
        for (var item in result['commonPrefixes']) {
            files.add(File(true,item['Prefix'],prefix));
        }
        print(result);
        for (var item in result['contents']) {
            if(item['Size'] == '0') {
                continue;
            }
            print(item);
            files.add(File(false,item['Key'],prefix,size: item['Size'],date:item['LastModified']));
        }
        setState(() {});
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                leading: null == prefix?null : IconButton(
                    icon: Icon(_backIcon()),
                    onPressed: () {
                        prefixS.removeLast();
                        if (prefixS.isEmpty) {
							prefix = null;
                            _pull();
                            jumpToPosition(false);
                        }
                        else {
                            prefix = prefixS.join('/')+"/";
                            _pull(prefix:prefix);
                            jumpToPosition(true);
                        }
                    }),
                title: Text('网盘盒子'),
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
                        onPressed:() {
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
            drawer: DrawerView(),
            body: Scaffold(
                appBar: PreferredSize(
                    child: AppBar(
                        elevation: 0.4,
                        centerTitle: false,
                        backgroundColor: Color(0xffeeeeee),
                        title: Text(
                            "${oss.bucketName}://"+(prefix==null?"":"$prefix"),
                            style: TextStyle(color: Colors.grey),
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
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).padding.top - 56.0),
                                        child: Center(
                                            child: Text('The folder is empty'),
                                        ),
                                    );
                                }
                            },
                        ),
                        onRefresh:() => _pull(prefix: prefix),
                        loadMore:() => _pull(clear:false,prefix: prefix,marker: marker),
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
                        leading: Image.asset(fileIcon(file)),
                        title: Row(
                            children: <Widget>[
                                Expanded(child: Text(file.name)),
                                //file.isDir? Text('${file.num}项',style: TextStyle(color: Colors.grey)):Container()
                            ],
                        ),
                        subtitle: file.isDir ? null:Text('${file.dateFmt()}  ${file.sizeFmt()}', style: TextStyle(fontSize: 12.0)),
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
                    prefixS.add(file.name);
                    prefix = prefixS.join('/')+"/";
                    print("prefix $prefix");
                    _pull(prefix:prefix);
                    jumpToPosition(true);
                }
                else {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => new PhotoGalleryPage([
                            'https://picbox.oss-cn-beijing.aliyuncs.com/0I3145F5-2.jpg',
                            'https://picbox.oss-cn-beijing.aliyuncs.com/1080-1.jpg'
                        ]))
                    );
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

class File {
    String prefix;
    bool isDir;
    String name;
    //String ext = 'png';
    String size;
    String date;
    
    File(this.isDir,this.name,this.prefix,{this.size,this.date}) {
        if(prefix == null) {
            if(isDir) name = name.replaceAll('/', '');
            return;
        }
        name = name.replaceFirst(prefix, '');
        if(isDir) name = name.replaceAll('/', '');
    }
    
    String ext() {
        return path.extension(name);
    }
    
    String sizeFmt() {
        String unit = 'kb';
        double s = double.parse(size);
        s = s/1024;
        if(s > 1024) {
            s = s/1024;
            unit = 'mb';
        }
        return '${s.toStringAsFixed(2)} $unit';
    }
    
    String dateFmt() {
        return '2019-12-15 8:00';
    }
}

fileIcon(File file) {
    try {
        String iconImg;
        if (file.isDir) {
            return 'assets/images/folder.png';
        }
        switch (file.ext()) {
            case '.ppt':
            case '.pptx':
                iconImg = 'assets/images/ppt.png';
                break;
            case '.doc':
            case '.docx':
                iconImg = 'assets/images/word.png';
                break;
            case '.xls':
            case '.xlsx':
                iconImg = 'assets/images/excel.png';
                break;
            case '.jpg':
            case '.jpeg':
            case '.png':
                iconImg = 'assets/images/image.png';
                break;
            case '.txt':
                iconImg = 'assets/images/txt.png';
                break;
            case '.mp3':
                iconImg = 'assets/images/mp3.png';
                break;
            case '.mp4':
                iconImg = 'assets/images/video.png';
                break;
            case '.rar':
            case '.zip':
                iconImg = 'assets/images/zip.png';
                break;
            case '.psd':
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