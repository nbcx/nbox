import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

enum GridPageTileStyle {
    imageOnly,
    oneLine,
    twoLine
}

typedef BannerTapCallback = void Function(Photo photo);

const double _kMinFlingVelocity = 800.0;
const String _kGalleryAssetsPackage = 'flutter_gallery_assets';

class CloudPage extends StatefulWidget {
  const CloudPage({ Key key }) : super(key: key);
  
  @override
  _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  
  GridPageTileStyle _tileStyle = GridPageTileStyle.twoLine;

  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  bool _loadMore = true;
  int indexPage = 1;
  List<String> data = [];
  
  void changeTileStyle(GridPageTileStyle value) {
      setState(() {
          _tileStyle = value;
      });
  }
  
  @override
  Widget build(BuildContext context) {
      final Orientation orientation = MediaQuery.of(context).orientation;
      return Scaffold(
          appBar: AppBar(
            title: const Text('Grid list'),
            actions: <Widget>[
              //MaterialDemoDocumentationButton(GridListDemo.routeName),
              PopupMenuButton<GridPageTileStyle>(
                onSelected: changeTileStyle,
                itemBuilder: (BuildContext context) => <PopupMenuItem<GridPageTileStyle>>[
                  const PopupMenuItem<GridPageTileStyle>(
                    value: GridPageTileStyle.imageOnly,
                    child: Text('Image only'),
                  ),
                  const PopupMenuItem<GridPageTileStyle>(
                    value: GridPageTileStyle.oneLine,
                    child: Text('One line'),
                  ),
                  const PopupMenuItem<GridPageTileStyle>(
                    value: GridPageTileStyle.twoLine,
                    child: Text('Two line'),
                  ),
                ],
              ),
            ],
          ),
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
                    padding: const EdgeInsets.all(4.0),
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
                    ),
                    itemCount: data.length,
                    itemBuilder: buildImage
                ),
                onRefresh: ()=>_onRefresh(),
                loadMore: ()=>_more(),
              )
          ),
      );
  }

  Widget buildImage(context, index) {
    return GridDemoPhotoItem(
        photo: Photo(
            assetName: data[index],
            assetPackage: _kGalleryAssetsPackage,
            title: 'Tanjore',
            caption: 'Thanjavur Temple',
        ),
        tileStyle: _tileStyle,
        onBannerTap: (Photo photo) {
          setState(() {
            photo.isFavorite = !photo.isFavorite;
          });
        },
    );
  }

  Future<void> _more() async {
      print('_more');
      if(!_loadMore) {
        return null;
      }
      Dio dio = new Dio();
      Response response;
    
      response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=美女&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
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
      response = await dio.get('http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=美女&tag2=%E5%85%A8%E9%83%A8&ie=utf8');
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
}

class Photo {
    Photo({
        this.assetName,
        this.assetPackage,
        this.title,
        this.caption,
        this.isFavorite = false,
    });
  
    final String assetName;
    final String assetPackage;
    final String title;
    final String caption;
  
    bool isFavorite;
    String get tag => assetName; // Assuming that all asset names are unique.
  
    bool get isValid => assetName != null && title != null && caption != null && isFavorite != null;
}

class GridPhotoViewer extends StatefulWidget {
    const GridPhotoViewer({ Key key, this.photo }) : super(key: key);
  
    final Photo photo;
  
    @override
    _GridPhotoViewerState createState() => _GridPhotoViewerState();
}

class _GridTitleText extends StatelessWidget {
    const _GridTitleText(this.text);
  
    final String text;
  
    @override
    Widget build(BuildContext context) {
      return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(text),
      );
    }
}

class _GridPhotoViewerState extends State<GridPhotoViewer> with SingleTickerProviderStateMixin {
    AnimationController _controller;
    Animation<Offset> _flingAnimation;
    Offset _offset = Offset.zero;
    double _scale = 1.0;
    Offset _normalizedOffset;
    double _previousScale;
  
    @override
    void initState() {
        super.initState();
        _controller = AnimationController(vsync: this)
          ..addListener(_handleFlingAnimation);
    }
  
    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }
  
    // The maximum offset value is 0,0. If the size of this renderer's box is w,h
    // then the minimum offset value is w - _scale * w, h - _scale * h.
    Offset _clampOffset(Offset offset) {
        final Size size = context.size;
        final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
        return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
    }
  
    void _handleFlingAnimation() {
        setState(() {
          _offset = _flingAnimation.value;
        });
    }
  
    void _handleOnScaleStart(ScaleStartDetails details) {
        setState(() {
          _previousScale = _scale;
          _normalizedOffset = (details.focalPoint - _offset) / _scale;
          // The fling animation stops if an input gesture starts.
          _controller.stop();
        });
    }
  
    void _handleOnScaleUpdate(ScaleUpdateDetails details) {
        setState(() {
          _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
          // Ensure that image location under the focal point stays in the same place despite scaling.
          _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
        });
    }
  
    void _handleOnScaleEnd(ScaleEndDetails details) {
        final double magnitude = details.velocity.pixelsPerSecond.distance;
        if (magnitude < _kMinFlingVelocity)
          return;
        final Offset direction = details.velocity.pixelsPerSecond / magnitude;
        final double distance = (Offset.zero & context.size).shortestSide;
        _flingAnimation = _controller.drive(Tween<Offset>(
          begin: _offset,
          end: _clampOffset(_offset + direction * distance),
        ));
        _controller
          ..value = 0.0
          ..fling(velocity: magnitude / 1000.0);
    }
  
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onScaleStart: _handleOnScaleStart,
        onScaleUpdate: _handleOnScaleUpdate,
        onScaleEnd: _handleOnScaleEnd,
        child: ClipRect(
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: new Image.network(
                widget.photo.assetName,
                //package: widget.photo.assetPackage,
                fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
}

class GridDemoPhotoItem extends StatelessWidget {
    GridDemoPhotoItem({
      Key key,
      @required this.photo,
      @required this.tileStyle,
      @required this.onBannerTap,
    }) : assert(photo != null && photo.isValid),
         assert(tileStyle != null),
         assert(onBannerTap != null),
         super(key: key);
  
    final Photo photo;
    final GridPageTileStyle tileStyle;
    final BannerTapCallback onBannerTap; // User taps on the photo's header or footer.
  
    void showPhoto(BuildContext context) {
      Navigator.push(context, MaterialPageRoute<void>(
        builder: (BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                    title: Text(photo.title),
                ),
                body: SizedBox.expand(
                  child: Hero(
                      tag: photo.tag,
                      child: GridPhotoViewer(photo: photo),
                  ),
                ),
            );
        }
      ));
    }
  
    @override
    Widget build(BuildContext context) {
      final Widget image = GestureDetector(
        onTap: () { showPhoto(context); },
        child: Hero(
          key: Key(photo.assetName),
          tag: photo.tag,
          child: new Image.network(
            photo.assetName,
            fit: BoxFit.cover,
          ),
          //child: Image.asset(
          //    photo.assetName,
          //    package: photo.assetPackage,
          //    fit: BoxFit.cover,
          //),
        ),
      );
  
      final IconData icon = photo.isFavorite ? Icons.star : Icons.star_border;
  
      switch (tileStyle) {
        case GridPageTileStyle.imageOnly:
          return image;
  
        case GridPageTileStyle.oneLine:
          return GridTile(
            header: GestureDetector(
              onTap: () { onBannerTap(photo); },
              child: GridTileBar(
                  title: _GridTitleText(photo.title),
                  backgroundColor: Colors.black45,
                  leading: Icon(
                    icon,
                    color: Colors.white,
                  ),
              ),
            ),
            child: image,
          );
  
        case GridPageTileStyle.twoLine:
            return GridTile(
                footer: GestureDetector(
                  onTap: () {
                    onBannerTap(photo);
                  },
                  child: GridTileBar(
                    backgroundColor: Colors.black45,
                    title: _GridTitleText(photo.title),
                    subtitle: _GridTitleText(photo.caption),
                    trailing: Icon(
                      icon,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: image,
            );
      }
      assert(tileStyle != null);
      return null;
    }
}


