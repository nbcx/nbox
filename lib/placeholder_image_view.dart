import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ColorValues {
    /// 图片占位背景色
    static const int IMAGE_PLACHEHOLDER_COLOR = 0xFFEEEEEE;
}

class PlaceholderImageView extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  PlaceholderImageView(this.imageUrl,
      {Key key, this.height, this.width, this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) => new Stack(children: <Widget>[
        new Container(
            color: const Color(ColorValues.IMAGE_PLACHEHOLDER_COLOR),
            width: width,
            height: height),
        new FadeInImage.memoryNetwork(
            image: imageUrl,
            placeholder: kTransparentImage,
            height: height,
            width: width,
            fit: fit)
      ]);
}
