// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'home.dart';
import 'collection.dart';
import 'event_bus.dart';
import 'login_page.dart';
import 'grid_list_page.dart';

class NavigationIconView {
	
	NavigationIconView({
		Widget icon,
		Widget activeIcon,
		String title,
		Color color,
		TickerProvider vsync,
	}) : _icon = icon,
			_color = color,
			_title = title,
			item = BottomNavigationBarItem(
				icon: icon,
				activeIcon: activeIcon,
				title: Text(title),
				backgroundColor: color,
			),
			controller = AnimationController(
				duration: kThemeAnimationDuration,
				vsync: vsync,
			) {
		_animation = controller.drive(CurveTween(
			curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
		));
	}
	
	final Widget _icon;
	final Color _color;
	final String _title;
	final BottomNavigationBarItem item;
	final AnimationController controller;
	Animation<double> _animation;
	
	FadeTransition transition(BottomNavigationBarType type, BuildContext context) {
		Color iconColor;
		if (type == BottomNavigationBarType.shifting) {
			iconColor = _color;
		}
		else {
			final ThemeData themeData = Theme.of(context);
			iconColor = themeData.brightness == Brightness.light
				? themeData.primaryColor
				: themeData.accentColor;
		}
		
		return FadeTransition(
			opacity: _animation,
			child: SlideTransition(
				position: _animation.drive(
					Tween<Offset>(
						begin: const Offset(0.0, 0.02), // Slightly down.
						end: Offset.zero,
					),
				),
				child: IconTheme(
					data: IconThemeData(
						color: iconColor,
						size: 120.0,
					),
					child: Semantics(
						label: 'Placeholder for $_title tab',
						child: _icon,
					),
				),
			),
		);
	}
}

class CustomIcon extends StatelessWidget {
	
	@override
	Widget build(BuildContext context) {
		final IconThemeData iconTheme = IconTheme.of(context);
		return Container(
			margin: const EdgeInsets.all(4.0),
			width: iconTheme.size - 8.0,
			height: iconTheme.size - 8.0,
			color: iconTheme.color,
		);
	}
}

class CustomInactiveIcon extends StatelessWidget {
	
	@override
	Widget build(BuildContext context) {
		final IconThemeData iconTheme = IconTheme.of(context);
		return Container(
			margin: const EdgeInsets.all(4.0),
			width: iconTheme.size - 8.0,
			height: iconTheme.size - 8.0,
			decoration: BoxDecoration(
				border: Border.all(color: iconTheme.color, width: 2.0),
			),
		);
	}
}

class NavigationPage extends StatefulWidget {
	static const String routeName = '/material/bottom_navigation';
	
	@override
	_NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with TickerProviderStateMixin {
	
	int _currentIndex = 0;
	BottomNavigationBarType _type = BottomNavigationBarType.shifting;
	List<NavigationIconView> _navigationViews;
	// 页面控制
	TabController _tabController;
	
	List<Widget> _tabView = <Widget>[
		BaiduMeituDemo(), Collection(), BaiduMeituDemo(),const GridListPage(),Collection()
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
		_navigationViews = <NavigationIconView>[
			NavigationIconView(
				icon: const Icon(Icons.access_alarm),
				title: 'Alarm',
				color: colors[0],
				vsync: this,
			),
			NavigationIconView(
				activeIcon: CustomIcon(),
				icon: CustomInactiveIcon(),
				title: 'Box',
				color: colors[1],
				vsync: this,
			),
			NavigationIconView(
				activeIcon: const Icon(Icons.cloud),
				icon: const Icon(Icons.cloud_queue),
				title: 'Cloud',
				color: colors[2],
				vsync: this,
			),
			NavigationIconView(
				activeIcon: const Icon(Icons.favorite),
				icon: const Icon(Icons.favorite_border),
				title: 'Favorites',
				color: colors[3],
				vsync: this,
			),
			NavigationIconView(
				icon: const Icon(Icons.event_available),
				title: 'Event',
				color: colors[4],
				vsync: this,
			),
		];
		
		_navigationViews[_currentIndex].controller.value = 1.0;
		
		//new
		_tabController = new TabController(initialIndex: 0, length: 5, vsync: this);
		_tabController.addListener(() {
			print('hello${_tabController.index}');
			bus.emit("tabchange", colors[_tabController.index]);
			setState((){});
		});
	}
	
	@override
	void dispose() {
		for (NavigationIconView view in _navigationViews)
			view.controller.dispose();
		super.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		final BottomNavigationBar botNavBar = BottomNavigationBar(
			items: _navigationViews
				.map<BottomNavigationBarItem>((NavigationIconView navigationView) => navigationView.item)
				.toList(),
			currentIndex: _tabController.index,
			type: _type,
			//iconSize: 4.0,
			onTap: _onBottomNavigationBarTap,
		);
		return Scaffold(
			body: TabBarView(
				controller: _tabController,
				children: _tabView,
			),
			bottomNavigationBar: botNavBar,
		);
	}
	
	
	// 底部栏切换
	void _onBottomNavigationBarTap(int index) {
		if(index == 4) {
			Navigator.of(context).push(MaterialPageRoute(builder: (context) => new LoginPage()));
			return null;
		}
		bus.emit("tabchange", colors[index]);
		print(index);
		setState(() {
			_tabController.index = index;
			
			_navigationViews[_currentIndex].controller.reverse();
			_currentIndex = index;
			_navigationViews[_currentIndex].controller.forward();
		});
	}
	
}
