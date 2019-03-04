import 'package:flutter/material.dart';
import 'package:picbox/colors.dart';
import 'package:picbox/session.dart';
import 'event_bus.dart';

class SettingAppPage extends StatelessWidget {
	
	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				title: Text('设置'),
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
									child: Text('主题'),
								)
							],
						),
						children: <Widget>[
							new Wrap(
								children: themeColorMap.keys.map((String key) {
									Color value = themeColorMap[key];
									return new InkWell(
										onTap: () {
											Session.putString('key_theme_color', key);
											bus.emit("themechange", key);
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
					new ListTile(
						title: new Row(
							children: <Widget>[
								Icon(
									Icons.language,
									color: Colours.gray_66,
								),
								Padding(
									padding: EdgeInsets.only(left: 10.0),
									child: Text('语言'),
								)
							],
						),
						trailing: Row(
							mainAxisSize: MainAxisSize.min,
							children: <Widget>[
								Text(
									'语言',
									//SpHelper.getLanguageModel() == null? IntlUtil.getString(context, Ids.languageAuto): IntlUtil.getString(context, SpHelper.getLanguageModel().titleId,languageCode: 'zh', countryCode: 'CH'),
									style: TextStyle(
										fontSize: 14.0,
										color: Colours.gray_99,
									)
								),
								Icon(Icons.keyboard_arrow_right)
							],
						),
						onTap: () {
							//NavigatorUtil.pushPage(context, LanguagePage(), pageName: Ids.titleLanguage);
						},
					)
				],
			),
		);
	}
}
