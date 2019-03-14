import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPage extends StatefulWidget {
	VideoPage({this.title = '视频'});
	
	final String title;
	
	@override
	_VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

	VideoPlayerController _videoPlayerController1;
	ChewieController _chewieController;
	
	@override
	void initState() {
		super.initState();

		_videoPlayerController1 = VideoPlayerController.network('https://start.7ve.cn/public/butterfly.mp4');
		_chewieController = ChewieController(
			videoPlayerController: _videoPlayerController1,
			aspectRatio: 3 / 2,
			autoPlay: true,
			looping: true,
			// Try playing around with some of these other options:
			
			showControls: true,
			// materialProgressColors: ChewieProgressColors(
			//   playedColor: Colors.red,
			//   handleColor: Colors.blue,
			//   backgroundColor: Colors.grey,
			//   bufferedColor: Colors.lightGreen,
			// ),
			placeholder: Container(
			   color: Colors.grey,
			),
			// autoInitialize: true,
		);
	}
	
	@override
	void dispose() {
		_videoPlayerController1.dispose();
		_chewieController.dispose();
		super.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.black,
				title: Text(widget.title),
			),
			backgroundColor: Colors.black,
			body: Chewie(
				controller: _chewieController,
			),
		);
	}
}