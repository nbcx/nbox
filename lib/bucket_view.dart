import 'package:flutter/material.dart';
import 'oss.dart';
import 'event_bus.dart';
import 'sqlite.dart';

class BucketView extends StatefulWidget {

	final Oss oss;

	BucketView(this.oss);
	
	@override
	_BucketViewState createState() => _BucketViewState();
}

class _BucketViewState extends State<BucketView> with AutomaticKeepAliveClientMixin {
	List data = List();
	
	@override
	bool get wantKeepAlive => true;

	@override
	void initState() {
		super.initState();
		_initBucket();
	}
	
	_initBucket() async{
		Map result = await widget.oss.buckets();
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
		//_MaterialListType _itemType = _MaterialListType.threeLine;
		Iterable<Widget> listTiles = data.map<Widget>((item) {
			return MergeSemantics(
				child: ListTile(
					title: Text(item['Name']),
					subtitle:Text(item['ExtranetEndpoint']),
					trailing: Radio<String>(
						value: item['Name'],
						groupValue: widget.oss.bucketName,
						//onChanged: changeItem,
					),
					onTap: ()=>changeBucket(item['Name'],item['ExtranetEndpoint']),
				),
			);
		});
		listTiles = ListTile.divideTiles(context: context, tiles: listTiles);
		
		return listTiles.toList();
	}

	void changeBucket(String name,String endpoint) {
		bus.emit('file_manage_page.changeBucket',{
			'name':name,
			'endpoint':endpoint
		});
		db.update('UPDATE cloud SET bucket=?,endpoint=? WHERE enable = ?',
			[name, endpoint, 1]
		);
		Navigator.pop(context);
	}
	
}