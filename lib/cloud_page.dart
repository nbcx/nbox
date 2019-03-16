import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'cloud_setting_page.dart';
import 'sqlite.dart';
import 'event_bus.dart';
import 'cloud.dart';

class CloudPage extends StatefulWidget {

    @override
    _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    ShapeBorder _shape;

    List<Cloud> clouds = [];
    
    @override
    void initState() {
        super.initState();
        _destinations();
        bus.on("cloud_page.changeCloud", (arg) {
            _destinations();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: const Text('云端'),
                actions: <Widget>[
                    //MaterialDemoDocumentationButton(CardsDemo.routeName),
                    IconButton(
                        icon: const Icon(
                            Icons.add,
                            semanticLabel: 'add cloud',
                        ),
                        onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudSettingPage()));
                        },
                    ),
                ],
            ),
            body: ListView(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                children: clouds.map<Widget>((Cloud destination) {
                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Item(cloud: destination, shape: _shape),
                    );
                }).toList(),
            ),
        );
    }

    _destinations() async {
        List data = await db.gets("SELECT * FROM cloud");
        print(data);
        if(data.length < 1) {
            return null;
        }
        clouds.clear();
        for (var item in data) {
            clouds.add(Cloud.page(item));
        }
        setState(() {});
    }
}



class Item extends StatefulWidget {
    
    const Item({Key key, @required this.cloud, this.shape }) : assert(cloud != null),super(key: key);

    final Cloud cloud;
    final ShapeBorder shape;
    
    @override
    _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
    
    static const double height = 150.0;

    @override
    Widget build(BuildContext context) {

        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        
        return SafeArea(
            top: false,
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SizedBox(
                    height: height,
                    child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: widget.shape,
                        child: InkWell(
                            onLongPress: ()=>_onLongPress(widget.cloud),
                            onTap: _onTap,
                            splashColor: colorScheme.onSurface.withOpacity(0.12),
                            highlightColor: Colors.transparent,
                            child: Stack(
                                children: <Widget>[
                                    Container(color: widget.cloud.enable ==1 ? colorScheme.primary.withOpacity(0.08) : Colors.transparent ),
                                    TravelDestinationContent(cloud: widget.cloud),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                                Icons.check_circle,
                                                color: widget.cloud.enable == 1 ? colorScheme.primary : Colors.transparent,
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );
    }

    void _onLongPress(Cloud cloud) {
        if(cloud.enable == 1) {
            return;
        }
        db.update('UPDATE cloud SET enable = ?  WHERE enable = ?',
            [0, 1]
        );
        db.update('UPDATE cloud SET enable = ?  WHERE id = ?',
            [1, cloud.id]
        );
        bus.emit('cloud_page.changeCloud');
        bus.emit('file_manage_page.changeAccount',cloud);
    }

    void _onTap() {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudSettingPage(
            id:widget.cloud.id
        )));
    }

}

class TravelDestinationContent extends StatelessWidget {
    
    const TravelDestinationContent({Key key, @required this.cloud}) : assert(cloud != null), super(key: key);
    
    final Cloud cloud;
    
    @override
    Widget build(BuildContext context) {
        
        final ThemeData theme = Theme.of(context);
        final TextStyle descriptionStyle = theme.textTheme.subhead;
        
        final List<Widget> children = <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: descriptionStyle,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            // three line description
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(cloud.name,textScaleFactor: 1.1),
                            ),
                            Text(cloud.key,style: descriptionStyle.copyWith(color: Colors.black54)),
                            Text(cloud.bucket+"."+cloud.endpoint,style: descriptionStyle.copyWith(color: Colors.black54)),
                        ],
                    ),
                ),
            ),
            ButtonTheme.bar(
                padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 8.0),
                child: ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: <Widget>[
                        FlatButton(
                            child: Text('删除'),
                            textColor: Colors.red,
                            onPressed: () {
                                print('删除');
                            },
                        ),
                    ],
                ),
            )
        ];

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
        );
    }
}

