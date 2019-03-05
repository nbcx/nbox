import 'package:flutter/material.dart';

import 'home.dart';
import 'collection.dart';
import 'login_page.dart';
import 'grid_list_page.dart';
import 'setting_page.dart';
import 'search_page.dart';



class NavigationPage extends StatefulWidget {
	
	@override
	_NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with SingleTickerProviderStateMixin {
	
	//int _currentIndex = 0;
	//BottomNavigationBarType _type = BottomNavigationBarType.shifting;
	//List<NavigationIconView> _navigationViews;
	// 页面控制
	TabController _tabController;
	
	List<Widget> _tabView = <Widget>[
		SearchPage(), Collection(), AboutPage(),GridListPage(),Collection()
	];
	
	List<Color> colors = [
		Colors.deepPurple,
		Colors.deepOrange,
		Colors.teal,
		Colors.indigo,
		Colors.pink
	];
	
	@override
	bool get wantKeepAlive => true;
	
	@override
	void initState() {
		super.initState();
		
		//new
		_tabController = new TabController(initialIndex: 0, length: 5, vsync: this);
		_tabController.addListener(() {
			setState((){});
		});
	}
	
	//@override
	//void dispose() {
	//	for (NavigationIconView view in _navigationViews)
	//		view.controller.dispose();
	//	super.dispose();
	//}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: TabBarView(
				controller: _tabController,
				children: _tabView,
			),
			bottomNavigationBar: BottomNavigationBar(
				currentIndex: _tabController.index,
				type: BottomNavigationBarType.fixed,
				fixedColor: Colors.black,
				onTap: _onBottomNavigationBarTap,
				items: <BottomNavigationBarItem>[
					BottomNavigationBarItem(
						icon: Icon(Icons.dashboard),
						title: Text('发现')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.style),
						title: Text('分类')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.person),
						title: Text('我')
					)
				],
			),
		);
	}
	
	
	// 底部栏切换
	void _onBottomNavigationBarTap(int index) {
		if(index == 4) {
			Navigator.of(context).push(MaterialPageRoute(builder: (context) => new LoginPage()));
			return null;
		}
		setState(() {
			_tabController.index = index;
		});
	}
	
}
