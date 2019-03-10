import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'cloud_setting_page.dart';
import 'sqlite.dart';

const String _kGalleryAssetsPackage = 'flutter_gallery_assets';

enum CardDemoType {
    standard,
    selectable,
}

class CloudPage extends StatefulWidget {

    @override
    _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
    ShapeBorder _shape;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('云端'),
                actions: <Widget>[
                    //MaterialDemoDocumentationButton(CardsDemo.routeName),
                    IconButton(
                        icon: const Icon(
                            Icons.sentiment_very_satisfied,
                            semanticLabel: 'update shape',
                        ),
                        onPressed: () {
                            setState(() {
                                _shape = _shape != null ? null : const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        topRight: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(2.0),
                                        bottomRight: Radius.circular(2.0),
                                    ),
                                );
                            });
                        },
                    ),
                ],
            ),
            body: ListView(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                children: destinations.map<Widget>((TravelDestination destination) {
                    Widget child;
                    switch (destination.type) {
                        case CardDemoType.standard:
                            child = TravelDestinationItem(destination: destination, shape: _shape);
                            break;
                        case CardDemoType.selectable:
                            child = SelectableTravelDestinationItem(destination: destination, shape: _shape);
                            break;
                    }

                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: child,
                    );
                }).toList(),
            ),
        );
    }
}


class TravelDestination {
    
    const TravelDestination({
        @required this.assetName,
        @required this.assetPackage,
        @required this.title,
        @required this.description,
        @required this.city,
        @required this.location,
        this.type = CardDemoType.standard,
    }) : assert(assetName != null),
            assert(assetPackage != null),
            assert(title != null),
            assert(description != null),
            assert(city != null),
            assert(location != null);
    
    final String assetName;
    final String assetPackage;
    final String title;
    final String description;
    final String city;
    final String location;
    final CardDemoType type;
}

const List<TravelDestination> destinations = <TravelDestination>[
    TravelDestination(
        assetName: 'places/india_thanjavur_market.png',
        assetPackage: _kGalleryAssetsPackage,
        title: 'Top 10 Cities to Visit in Tamil Nadu',
        description: '七度',
        city: 'Thanjavur',
        location: 'Thanjavur, Tamil Nadu',
    ),
    TravelDestination(
        assetName: 'places/india_tanjore_thanjavur_temple.png',
        assetPackage: _kGalleryAssetsPackage,
        title: 'Brihadisvara Temple',
        description: '阿里OSS空间',
        city: 'Thanjavur',
        location: 'Thanjavur, Tamil Nadu',
        type: CardDemoType.selectable,
    ),
];

class TravelDestinationItem extends StatelessWidget {
    
    const TravelDestinationItem({ Key key, @required this.destination, this.shape })
        : assert(destination != null),
            super(key: key);
    
    static const double height = 156.0;
    final TravelDestination destination;
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


class SelectableTravelDestinationItem extends StatefulWidget {
    
    const SelectableTravelDestinationItem({ Key key, @required this.destination, this.shape })
        : assert(destination != null),
            super(key: key);
    
    final TravelDestination destination;
    final ShapeBorder shape;
    
    @override
    _SelectableTravelDestinationItemState createState() => _SelectableTravelDestinationItemState();
}

class _SelectableTravelDestinationItemState extends State<SelectableTravelDestinationItem> {
    
    // This height will allow for all the Card's content to fit comfortably within the card.
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
                                // This ensures that the Card's children (including the ink splash) are clipped correctly.
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
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudSettingPage()));
                                    },
                                    // Generally, material cards use onSurface with 12% opacity for the pressed state.
                                    splashColor: colorScheme.onSurface.withOpacity(0.12),
                                    // Generally, material cards do not have a highlight overlay.
                                    highlightColor: Colors.transparent,
                                    child: Stack(
                                        children: <Widget>[
                                            Container(
                                                color: _isSelected
                                                // Generally, material cards use primary with 8% opacity for the selected state.
                                                // See: https://material.io/design/interaction/states.html#anatomy
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
    
    final TravelDestination destination;
    
    @override
    Widget build(BuildContext context) {
        
        final ThemeData theme = Theme.of(context);
        final TextStyle descriptionStyle = theme.textTheme.subhead;
        
        final List<Widget> children = <Widget>[
            // Description and share/explore buttons.
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
        
        if (destination.type == CardDemoType.standard) {
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
        }
        
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


