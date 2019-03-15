import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:picbox/setting_app_page.dart';
import 'package:picbox/cloud_page.dart';
import 'package:picbox/login_page.dart';
import 'package:picbox/oss.dart';

class DrawerView extends StatefulWidget {
	final Oss oss;
	
	DrawerView(this.oss);
	
	@override
	_DrawerViewState createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> with TickerProviderStateMixin {

	static const List<Map> _drawerContents = <Map>[
		{
			'icon':Icons.settings,
			'name':'系统设置',
			'action':'system'
		},
		{
			'icon':Icons.account_box,
			'name':'网盘账户管理',
			'action':'cloud'
		},
		{
			'icon':Icons.turned_in_not,
			'name':'关于',
			'action':'video'
		},
		{
			'icon':Icons.new_releases,
			'name':'版本更新',
			'action':'test'
		}
	];
	
	static final Animatable<Offset> _drawerDetailsTween = Tween<Offset>(
		begin: const Offset(0.0, -1.0),
		end: Offset.zero,
	).chain(CurveTween(
		curve: Curves.fastOutSlowIn,
	));
	
	AnimationController _controller;
	Animation<double> _drawerContentsOpacity;
	Animation<Offset> _drawerDetailsPosition;
	bool _showDrawerContents = true;
	
	@override
	void initState() {
		super.initState();
		_controller = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 200),
		);
		_drawerContentsOpacity = CurvedAnimation(
			parent: ReverseAnimation(_controller),
			curve: Curves.fastOutSlowIn,
		);
		_drawerDetailsPosition = _controller.drive(_drawerDetailsTween);
	}
	
	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}
	
	void _showNotImplementedMessage(String action) {
		Navigator.pop(context); // Dismiss the drawer.
		switch(action) {
			case 'system':
				Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingAppPage()));
				break;
			case 'cloud':
				Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudPage()));
				break;
			case 'video':
				break;
			case 'test':
				Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
				break;
		}
		
	}
	
	@override
	Widget build(BuildContext context) {
		return Drawer(
			child: Column(
				children: <Widget>[
					UserAccountsDrawerHeader(
						accountName: Text(widget.oss.bucketName),
						accountEmail: Text(widget.oss.accessid),
						currentAccountPicture: const CircleAvatar(
							backgroundImage: AssetImage('assets/images/nbcx.png'),
						),
						margin: EdgeInsets.zero,
						onDetailsPressed: () {
							_showDrawerContents = !_showDrawerContents;
							if (_showDrawerContents)
								_controller.reverse();
							else
								_controller.forward();
						},
					),
					MediaQuery.removePadding(
						context: context,
						// DrawerHeader consumes top MediaQuery padding.
						removeTop: true,
						child: Expanded(
							child: ListView(
								dragStartBehavior: DragStartBehavior.down,
								padding: const EdgeInsets.only(top: 8.0),
								children: <Widget>[
									Stack(
										children: <Widget>[
											// The initial contents of the drawer.
											FadeTransition(
												opacity: _drawerContentsOpacity,
												child: Column(
													mainAxisSize: MainAxisSize.min,
													crossAxisAlignment: CrossAxisAlignment.stretch,
													children: _drawerContents.map<Widget>((Map item) {
														return ListTile(
															leading: IconButton(
																icon: Icon(item['icon']),
															),//CircleAvatar(child: Text(item['icon'])),
															title: Text(item['name']),
															onTap: ()=>_showNotImplementedMessage(item['action']),
														);
													}).toList(),
												),
											),
											// The drawer's "details" view.
											SlideTransition(
												position: _drawerDetailsPosition,
												child: FadeTransition(
													opacity: ReverseAnimation(_drawerContentsOpacity),
													child: Column(
														mainAxisSize: MainAxisSize.min,
														crossAxisAlignment: CrossAxisAlignment.stretch,
														children: <Widget>[
															ListTile(
																leading: const Icon(Icons.add),
																title: const Text('Add account'),
																//onTap: _showNotImplementedMessage,
															),
															ListTile(
																leading: const Icon(Icons.settings),
																title: const Text('Manage accounts'),
																//onTap: _showNotImplementedMessage,
															),
														],
													),
												),
											),
										],
									),
								],
							),
						),
					),
				],
			),
		);
	}

}
