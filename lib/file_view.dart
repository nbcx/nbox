import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'oss.dart';

class FileView extends StatefulWidget {
    @override
    _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> with AutomaticKeepAliveClientMixin {
    
    List<File> files = [
        File(true, 'Music', 12, 'png'),
        File(true, 'Podcasts', 12, 'png'),
        File(false, 'teusic.txt', 12, 'txt'),
        File(false, 'Music.png', 12, 'png'),
    ];

    @override
    bool get wantKeepAlive => true;
    
    MethodChannel _channel = MethodChannel('openFileChannel');
    Directory parentDir;
    ScrollController controller = ScrollController();
    int count = 0; // 记录当前文件夹中以 . 开头的文件和文件夹
    String sDCardDir;
    List<double> position = [];
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        _initFiles();
    }
    
    _initFiles() async {
        Map result = await Oss().bucket();
        print(result['commonPrefixes']);
        //for (var item in files['commonPrefixes']) {
        //
        //}
        for (var item in result['contents']) {
            files.add(File(false,item['Key'],0,'png'));
        }
        setState(() {});
    }
    
    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () {
                if (parentDir.path != sDCardDir) {
                    jumpToPosition(false);
                } else {
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
                    preferredSize: Size.fromHeight(30)),
                /*
                appBar: AppBar(
                    title: Text(
                        '当前库',
                        style: TextStyle(color: Colors.black),
                    ),
                    elevation: 0.4,
                    centerTitle: true,
                    backgroundColor: Color(0xffeeeeee),
                    leading: parentDir?.path == sDCardDir
                        ? Container()
                        : IconButton(
                        icon: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                        ),
                        onPressed: () {
                            if (parentDir.path != sDCardDir) {
                                jumpToPosition(false);
                            } else {
                                Navigator.pop(context);
                            }
                        }),
                ),
                */
                backgroundColor: Color(0xfff3f3f3),
                body: Scrollbar(
                    child: ListView.builder(
                        controller: controller,
                        itemCount: files.length != 0 ? files.length : 1,
                        itemBuilder: (BuildContext context, int index) {
                            if (files.length != 0)
                                return buildListViewItem(files[index]);
                            else
                                return Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).padding.top - 56.0),
                                    child: Center(
                                        child: Text('The folder is empty'),
                                    ),
                                );
                        },
                    ),
                )),
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
                                !file.isDir
                                    ? Container()
                                    : Text(
                                    '${file.num}项',
                                    style: TextStyle(color: Colors.grey),
                                )
                            ],
                        ),
                        subtitle: !file.isDir
                            ? Text(
                            '11111111  132kb',
                            style: TextStyle(fontSize: 12.0),
                        )
                            : null,
                        trailing: !file.isDir ? null : Icon(Icons.chevron_right),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Divider(
                            height: 1.0,
                        ),
                    )
                ],
            ),
            onTap: () {
                if (file.isDir) {
                    //position.insert(position.length, controller.offset);
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
        if (isEnter)
            controller.jumpTo(0.0);
        else {
            controller.jumpTo(position[position.length - 1]);
            position.removeLast();
        }
    }
    
    openFile(String path) {
        final Map<String, dynamic> args = <String, dynamic>{'path': path};
        _channel.invokeMethod('openFile', args);
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

/// A custom widget that lets clicks have the effect of changing the background color
class ClickEffect extends StatefulWidget {
    ClickEffect(
        {Key key,
            this.margin,
            this.padding,
            this.normalColor: Colors.transparent,
            this.selectColor: const Color(0xffcccccc),
            @required this.onTap,
            @required this.child})
        : super(key: key);
    
    final EdgeInsetsGeometry margin;
    
    final EdgeInsetsGeometry padding;
    
    final Color normalColor;
    
    final Color selectColor;
    
    final GestureTapCallback onTap;
    
    final Widget child;
    
    @override
    _ClickEffectState createState() => _ClickEffectState();
}

class _ClickEffectState extends State<ClickEffect> {
    Color color;
    
    @override
    void initState() {
        super.initState();
        color = widget.normalColor;
    }
    
    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            child: Container(
                margin: widget.margin,
                padding: widget.padding,
                child: widget.child,
                color: color,
            ),
            onTap: widget.onTap,
            onTapDown: (_) {
                setState(() {
                    color = widget.selectColor;
                });
            },
            onTapUp: (_) {
                setState(() {
                    color = widget.normalColor;
                });
            },
            onTapCancel: () {
                setState(() {
                    color = widget.normalColor;
                });
            },
        );
    }
}