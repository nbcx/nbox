import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'oss.dart';

class PhotoGalleryPage extends StatefulWidget {
      final Oss oss;
      final List<String> images;
      final int index;
      final PageController pageController;
      final Widget loadingChild;
      final Decoration backgroundDecoration = const BoxDecoration(
          color: Colors.black,
      );
      
      PhotoGalleryPage(this.oss,this.index,this.images,{this.loadingChild}) : pageController = PageController(initialPage: index);
    
      @override
      State<StatefulWidget> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
    
    int currentIndex;
    List<PhotoViewGalleryPageOptions> _photoViewGalleryPageOptions;
    
    @override
    void initState() {
        currentIndex = widget.index;
        super.initState();
        _photoViewGalleryPageOptions = _photoViewGallery();
    }
    
    void onPageChanged(int index) {
        setState(() {
            currentIndex = index;
        });
    }
    
    void _pop() {
        Navigator.of(context).pop();
    }
    
    List<PhotoViewGalleryPageOptions> _photoViewGallery() {
        
        return widget.images.map((item) {
            return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.oss.objectUrl(item)),//widget.imageProvider,
                heroTag: "item",
            );
        }).toList();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: GestureDetector(
                child:Container(
                    decoration: widget.backgroundDecoration,
                    constraints: BoxConstraints.expand(
                        height: MediaQuery.of(context).size.height,
                    ),
                    child: Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                            PhotoViewGallery(
                                scrollPhysics: const BouncingScrollPhysics(),
                                pageOptions: _photoViewGalleryPageOptions,
                                loadingChild: widget.loadingChild,
                                backgroundDecoration: widget.backgroundDecoration,
                                pageController: widget.pageController,
                                onPageChanged: onPageChanged,
                            ),
                            Container(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                    "${widget.images.length}/${currentIndex + 1}",
                                    style: const TextStyle(color: Colors.white, fontSize: 17.0, decoration: null),
                                ),
                            )
                        ],
                    )
                ),
                onTap: _pop,
            ),
        );
    }
}
