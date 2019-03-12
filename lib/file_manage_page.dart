import 'package:flutter/material.dart';
import 'search_result_view.dart';
import 'file_view.dart';

enum DismissDialogAction {
    cancel,
    discard,
    save,
}
class FileManagePage extends StatefulWidget {

  @override
  _FileManagePageState createState() => _FileManagePageState();
  
}

class _FileManagePageState extends State<FileManagePage> {
  
    final _SearchDemoSearchDelegate _delegate = _SearchDemoSearchDelegate();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    int _lastIntegerSelected;
  
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: const Text('当前库'),
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
                    /**/
                    IconButton(
                        icon: Icon(
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Icons.more_horiz
                                : Icons.more_vert,
                        ),
                        tooltip: 'Show menu',
                        onPressed: (){
                            showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
                                return Container(
                                    child: Padding(
                                        padding: const EdgeInsets.all(132.0),
                                        child: Text('This is the modal bottom sheet. Tap anywhere to dismiss.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context).accentColor,
                                                fontSize: 24.0
                                            )
                                        )
                                    )
                                );
                            });
                            /*
                            Navigator.push(context, MaterialPageRoute<DismissDialogAction>(
                                builder: (BuildContext context) => ListDemo(),
                                fullscreenDialog: true,
                            ));
                            */
                            //return _bottomSheet == null ? _showConfigurationSheet : null;
                        }
                    ),

                ],
            ),
            body: FileView(),//SearchResultView(),
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
    return SearchResultView();//search: query
    
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
