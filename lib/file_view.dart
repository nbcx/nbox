import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'oss.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'event_bus.dart';
import 'click_effect.dart';

class FileView extends StatefulWidget {
    @override
    _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> with AutomaticKeepAliveClientMixin {
    
    GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
    
    List<File> files = [];

    @override
    bool get wantKeepAlive => true;
    
    MethodChannel _channel = MethodChannel('openFileChannel');
    ScrollController controller = ScrollController();
    int count = 0; // 记录当前文件夹中以 . 开头的文件和文件夹
    String sDCardDir;
    List<double> position = [];
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        bus.on("uploads", (arg) {
            _uploads();
        });
    }
    
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
        return WillPopScope(
            onWillPop: () {
                if (null != sDCardDir) {
                    jumpToPosition(false);
                }
                else {
                    SystemNavigator.pop();
                }
            },
            child: Scaffold(
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
            ),
            
        );
    }
    
    buildListViewItem(File file) {
        return ClickEffect(
            child: Column(
                children: <Widget>[
                    ListTile(
                        leading: Image.asset(selectIcon(file)),
                        title: Row(
                            children: <Widget>[
                                Expanded(child: Text(file.name)),
                                !file.isDir? Container(): Text('${file.num}项',style: TextStyle(color: Colors.grey))
                            ],
                        ),
                        subtitle: !file.isDir? Text('11111111  132kb', style: TextStyle(fontSize: 12.0)): null,
                        trailing: !file.isDir ? null : Icon(Icons.chevron_right),
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
                    jumpToPosition(true);
                }
                else {
                    //openFile(file.path);
                }
                
            },
        );
    }
    
    void jumpToPosition(bool isEnter) {
        print(isEnter);isEnter=false;
        if (isEnter) {
            controller.jumpTo(0.0);
        }
        else {
            controller.jumpTo(position[position.length - 1]);
            position.removeLast();
        }
    }
    
}

/// A custom widget that lets clicks have the effect of changing the background color


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