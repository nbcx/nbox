import 'package:flutter/material.dart';
import 'package:picbox/colors.dart';
import 'event_bus.dart';
import 'config.dart';
import 'translations.dart';
import 'language_page.dart';

class SettingAppPage extends StatefulWidget {

	@override
	State<StatefulWidget> createState() => _SettingAppPageState();



}

class _SettingAppPageState  extends State<SettingAppPage> {

	Translations trans;

	@override
	Widget build(BuildContext context) {

		trans = Translations.of(context);

		return new Scaffold(
			appBar: AppBar(
				title: Text(trans.text('systemSetting')),
				centerTitle: true,
			),
			body: ListView(
				children: <Widget>[
					new ExpansionTile(
						title: new Row(
							children: <Widget>[
								Icon(
									Icons.color_lens,
									color: Colours.gray_66,
								),
								Padding(
									padding: EdgeInsets.only(left: 10.0),
									child: Text(trans.text('theme')),
								)
							],
						),
						children: <Widget>[
							new Wrap(
								children: themeColorMap.keys.map((String key) {
									Color value = themeColorMap[key];
									return new InkWell(
										onTap: () {
											conf.updateThemeColor(key);
											bus.emit("main.themeChange", key);
										},
										child: new Container(
											margin: EdgeInsets.all(5.0),
											width: 36.0,
											height: 36.0,
											color: value,
										),
									);
								}).toList(),
							)
						],
					),
					ListTile(
						title: new Row(
							children: <Widget>[
								Icon(
									Icons.language,
									color: Colours.gray_66,
								),
								Padding(
									padding: EdgeInsets.only(left: 10.0),
									child: Text(trans.text('lang')),
								)
							],
						),
						trailing: Row(
							mainAxisSize: MainAxisSize.min,
							children: <Widget>[
								Text(
									'语言',
									style: TextStyle(
										fontSize: 14.0,
										color: Colours.gray_99,
									)
								),
								Icon(Icons.keyboard_arrow_right)
							],
						),
						onTap: () {
							Navigator.of(context).push(MaterialPageRoute(builder: (context) => LanguagePage()));
						},
					)
				],
			),
		);
	}
}