import 'package:flutter/material.dart';

import 'home.dart';
import 'collection.dart';
import 'login_page.dart';
import 'cloud_page.dart';
import 'setting_page.dart';
import 'search_page.dart';


class NavigationPage extends StatefulWidget {
	
	@override
	_NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with SingleTickerProviderStateMixin {
	
	// 页面控制
	TabController _tabController;
	
	List<Widget> _tabView = <Widget>[
		SearchPage(), Collection(), CloudPage(), AboutPage(),Collection()
	];
	
	List<Color> colors = [
		Colors.deepPurple,
		Colors.deepOrange,
		Colors.teal,
		Colors.indigo,
		Colors.pink
	];
	
	@override
	void initState() {
		super.initState();
		//new
		_tabController = new TabController(initialIndex: 0, length: 5, vsync: this);
		_tabController.addListener(() {
			setState((){});
		});
	}
	
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
						title: Text('推荐')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.style),
						title: Text('探索')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.cloud),
						title: Text('云端')
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
