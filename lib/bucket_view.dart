import 'package:flutter/material.dart';
import 'oss.dart';

/// 基本使用页面
class BucketView extends StatefulWidget {
	
	@override
	_BucketViewState createState() => _BucketViewState();
}

class _BucketViewState extends State<BucketView> with AutomaticKeepAliveClientMixin {
	
	List data = List();
	String search = '美女';
	
	@override
	bool get wantKeepAlive => true;
	
	
	@override
	void initState() {
		// TODO: implement initState
		super.initState();
		_initBucket();
	}
	
	_initBucket() async{
		Map result = await Oss().buckets();
		print(result);
		setState(() {
			data.addAll(result['bucket']);
		});
		print(data[0]['Name']);
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: ListView(
					padding: EdgeInsets.symmetric(vertical: 8.0),
					children: buildItem(context),
				),
			),
		);
	}
	
	List<Widget> buildItem(BuildContext context) {
		if(data.length == 0) {
			return [];
		}
		Iterable<Widget> listTiles = data.map<Widget>((item) {
			return MergeSemantics(
				child: ListTile(
					title: Text(item['Name']),
					subtitle:Text(item['ExtranetEndpoint'])
				),
			);
		});
		listTiles = ListTile.divideTiles(context: context, tiles: listTiles);
		
		return listTiles.toList();
	}
	
}
