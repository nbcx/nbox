import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoGalleryPage extends StatefulWidget {
  final List<String> images;
  PhotoGalleryPage(this.images);

  @override
  State<StatefulWidget> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  void _pop() {
    Navigator.of(context).pop();
  }

  Widget _buildItem(int index, List<String> images) => new GestureDetector(
        child: new PhotoView(
            loadingChild: new Center(child: const CircularProgressIndicator()),
            imageProvider: new NetworkImage(images[index]),
            heroTag: images[index]),
        onTap: _pop,
      );

  @override
  Widget build(BuildContext context) {
    final Widget body = new PageView.builder(
        itemCount: widget.images.length,
        itemBuilder: (context, index) => _buildItem(index, widget.images));

    return new Container(child: body);
  }
}
