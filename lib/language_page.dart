import 'package:flutter/material.dart';
import 'event_bus.dart';
import 'config.dart';
import 'translations.dart';

class LanguagePage extends StatefulWidget {

    @override
    State<StatefulWidget> createState() => _LanguagePageState();

}

class _LanguagePageState extends State<LanguagePage> {

    List lang = conf.supportedLanguages;
    Translations trans;

    @override
    Widget build(BuildContext context) {

        trans = Translations.of(context);

        return new Scaffold(
          appBar: AppBar(
              title: Text(
                  trans.text('i18n'),
                  style: TextStyle(fontSize: 16.0),
              ),
          ),
          body: ListView.builder(
              itemCount: lang.length,
              itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      title: Text(trans.text(lang[index]),
                          style: TextStyle(fontSize: 13.0),
                      ),
                      trailing: Radio(
                          value: lang[index],
                          groupValue: conf.k['lang'],
                          activeColor: Colors.indigoAccent,
                      ),
                      onTap: () {
                          conf.updateLanguage(lang[index]);
                          bus.emit("main.langChange", Locale(lang[index],''));
                      },
                  );
              }),
        );
    }
}
