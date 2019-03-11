import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'cloud_setting_page.dart';
import 'sqlite.dart';

class CloudPage extends StatefulWidget {

    @override
    _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
    ShapeBorder _shape;

    List<Data> destinations = [];
    
    @override
    void initState() {
        super.initState();
        _destinations();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
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
                children: destinations.map<Widget>((Data destination) {
                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Item(destination: destination, shape: _shape),
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
        for (var item in data) {
            destinations.add(Data(
                id:item['id'],
                assetName: 'places/india_thanjavur_market.png',
                assetPackage: 'flutter_gallery_assets',
                title: 'Top 10 Cities to Visit in Tamil Nadu',
                description: item['name'],
                city: 'Thanjavur',
                location: 'Thanjavur, Tamil Nadu',
            ));
        }
        setState(() {});
    }
}

class Data {
    const Data({
        @required this.id,
        @required this.assetName,
        @required this.assetPackage,
        @required this.title,
        @required this.description,
        @required this.city,
        @required this.location,
    }) : assert(assetName != null),
            assert(assetPackage != null),
            assert(title != null),
            assert(description != null),
            assert(city != null),
            assert(location != null);
    final int id;
    final String assetName;
    final String assetPackage;
    final String title;
    final String description;
    final String city;
    final String location;
}

class Item extends StatefulWidget {
    
    const Item({ Key key, @required this.destination, this.shape })
        : assert(destination != null),
            super(key: key);
    
    final Data destination;
    final ShapeBorder shape;
    
    @override
    _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
    
    static const double height = 156.0;
    bool _isSelected = false;
    
    @override
    Widget build(BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        
        return SafeArea(
            top: false,
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                    children: <Widget>[
                        SizedBox(
                            height: height,
                            child: Card(
                                clipBehavior: Clip.antiAlias,
                                shape: widget.shape,
                                child: InkWell(
                                    onLongPress: () {
                                        print('Selectable card state changed');
                                        setState(() {
                                            _isSelected = !_isSelected;
                                        });
                                    },
                                    onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudSettingPage(
                                            id:widget.destination.id
                                        )));
                                    },
                                    splashColor: colorScheme.onSurface.withOpacity(0.12),
                                    highlightColor: Colors.transparent,
                                    child: Stack(
                                        children: <Widget>[
                                            Container(
                                                color: _isSelected
                                                    ? colorScheme.primary.withOpacity(0.08)
                                                    : Colors.transparent,
                                            ),
                                            TravelDestinationContent(destination: widget.destination),
                                            Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(
                                                        Icons.check_circle,
                                                        color: _isSelected ? colorScheme.primary : Colors.transparent,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class SectionTitle extends StatelessWidget {
    const SectionTitle({
        Key key,
        this.title,
    }) : super(key: key);
    
    final String title;
    
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 12.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: Theme.of(context).textTheme.subhead),
            ),
        );
    }
}

class TravelDestinationContent extends StatelessWidget {
    
    const TravelDestinationContent({ Key key, @required this.destination })
        : assert(destination != null),
            super(key: key);
    
    final Data destination;
    
    @override
    Widget build(BuildContext context) {
        
        final ThemeData theme = Theme.of(context);
        final TextStyle descriptionStyle = theme.textTheme.subhead;
        
        final List<Widget> children = <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                                child: Text(
                                    destination.description,
                                    style: descriptionStyle.copyWith(color: Colors.black54),
                                ),
                            ),
                            Text(destination.city),
                            Text(destination.location),
                        ],
                    ),
                ),
            ),
        ];

        children.add(
            // share, explore buttons
            ButtonTheme.bar(
                child: ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: <Widget>[
                        FlatButton(
                            child: Text('SHARE', semanticsLabel: 'Share ${destination.title}'),
                            textColor: Colors.amber.shade500,
                            onPressed: () {
                                print('pressed');
                                _test();
                            },
                        ),
                        FlatButton(
                            child: Text('EXPLORE', semanticsLabel: 'Explore ${destination.title}'),
                            textColor: Colors.amber.shade500,
                            onPressed: () { print('pressed'); },
                        ),
                    ],
                ),
            ),
        );
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
        );
    }

    _test() async{
        Map m = await db.get('select * from cat where id=1');
        print(m);
    }
}

class TravelDestinationItem extends StatelessWidget {
    
    const TravelDestinationItem({ Key key, @required this.destination, this.shape })
        : assert(destination != null),
            super(key: key);
    
    static const double height = 156.0;
    final Data destination;
    final ShapeBorder shape;
    
    @override
    Widget build(BuildContext context) {
        return SafeArea(
            top: false,
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                    children: <Widget>[
                        //const SectionTitle(title: 'Normal'),
                        SizedBox(
                            height: height,
                            child: Card(
                                // This ensures that the Card's children are clipped correctly.
                                clipBehavior: Clip.antiAlias,
                                shape: shape,
                                child: TravelDestinationContent(destination: destination),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
    
}


