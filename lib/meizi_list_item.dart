import 'package:flutter/material.dart';
import 'placeholder_image_view.dart';
import 'photo_gallery_page.dart';


class DisPlayUtil {
    /// 获取屏幕宽度
    static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
}


class MeiZiListItem extends StatelessWidget {
  final String url;
  final int currentIndex;
  MeiZiListItem(this.url, {Key key, @required this.currentIndex}) : super(key: key);

  void _onPhotoTap(BuildContext context) => Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => new PhotoGalleryPage([url])));

  @override
  Widget build(BuildContext context) {
    double itemHeight = 500.0;
    double spacing = 8.0;
    double topSpacing = currentIndex == 0 ? spacing : 0.0;

    return new Container(
        height: itemHeight,
        margin: new EdgeInsets.only(top: topSpacing, bottom: spacing, left: spacing, right: spacing),
        child: new Hero(
            tag: this.url,
            child: new Card(
                margin: const EdgeInsets.all(0.0),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: new Stack(children: <Widget>[
                      new PlaceholderImageView(this.url,
                          width: DisPlayUtil.getScreenWidth(context),
                          height: itemHeight,
                          fit: BoxFit.cover
                      ),
                      new Material(
                          type: MaterialType.transparency,
                          child: new InkWell(onTap: () => _onPhotoTap(context))
                      )
                ])
            )
        )
    );
  }
}
