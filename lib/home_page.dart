import 'package:flutter/material.dart';
import 'search_result_view.dart';
import 'home_view.dart';

class SearchPage extends StatefulWidget {

  @override
  _SearchPageState createState() => _SearchPageState();
  
}

class _SearchPageState extends State<SearchPage> {
  
    final _SearchDemoSearchDelegate _delegate = _SearchDemoSearchDelegate();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
    int _lastIntegerSelected;
  
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: const Text('图片盒子'),
                actions: <Widget>[
                    IconButton(
                      tooltip: 'Search',
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final int selected = await showSearch<int>(
                            context: context,
                            delegate: _delegate,
                        );
                        if (selected != null && selected != _lastIntegerSelected) {
                            setState(() {
                                _lastIntegerSelected = selected;
                            });
                        }
                      },
                    ),
                    new PopupMenuButton(
                        icon:const Icon(Icons.add),
                        onSelected: (String value){
                            print("onSelected $value");
                        },
                        itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
                            new PopupMenuItem(
                                value:"选项一的内容",
                                child: new Text("选项一")
                            ),
                            new PopupMenuItem(
                                value: "选项二的内容",
                                child: new Text("选项二")
                            )
                        ]
                    ),
                    //MaterialDemoDocumentationButton(SearchDemo.routeName),
                    
                ],
            ),
            body: HomeView(),//SearchResultView(),
        );
    }
}

class _SearchDemoSearchDelegate extends SearchDelegate<int> {
  
  final List<int> _data = List<int>.generate(100001, (int i) => i).reversed.toList();
  final List<int> _history = <int>[42607, 85604, 66374, 44, 174];

  @override
  Widget buildLeading(BuildContext context) {
      return IconButton(
          tooltip: 'Back',
          icon: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress: transitionAnimation,
          ),
          onPressed: () {
              close(context, null);
          },
      );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    final Iterable<int> suggestions = query.isEmpty
        ? _history
        : _data.where((int i) => '$i'.startsWith(query));

    return _SuggestionList(
        query: query,
        suggestions: suggestions.map<String>((int i) => '$i').toList(),
        onSelected: (String suggestion) {
            query = suggestion;
            showResults(context);
        },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query == null) {
        return Center(
            child: Text('"$query"\n is not a valid integer between 0 and 100,000.\nTry again.',
              textAlign: TextAlign.center,
            ),
        );
    }
    return SearchResultView(search: query);
    
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {
                query = 'TODO: implement voice input';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                  query = '';
                  showSuggestions(context);
              },
            ),
    ];
  }
}

class _SuggestionList extends StatelessWidget {
    const _SuggestionList({this.suggestions, this.query, this.onSelected});
  
    final List<String> suggestions;
    final String query;
    final ValueChanged<String> onSelected;
  
    @override
    Widget build(BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int i) {
                final String suggestion = suggestions[i];
                return ListTile(
                    leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
                    title: RichText(
                      text: TextSpan(
                        text: suggestion.substring(0, query.length),
                        style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: suggestion.substring(query.length),
                            style: theme.textTheme.subhead,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                        onSelected(suggestion);
                    },
                );
            },
        );
    }
}
