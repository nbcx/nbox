import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'session.dart';
import 'sqlite.dart';

class CloudSettingPage extends StatefulWidget {
    const CloudSettingPage({ Key key }) : super(key: key);
    
    @override
    _CloudSettingPageState createState() => _CloudSettingPageState();
}

class _CloudSettingPageState extends State<CloudSettingPage> {
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    FormData fd = FormData();
    
    void showInSnackBar(String value) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(value)
        ));
    }
    
    bool _autovalidate = false;
    bool _formWasEdited = false;
    
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    
    void _handleSubmitted() async {
        final FormState form = _formKey.currentState;
        if (!form.validate()) {
            _autovalidate = true; // Start validating on every change.
            showInSnackBar('Please fix the errors in red before submitting.');
        }
        else {
            form.save();
            Session.putString('_domain', fd.domain);
            Session.putString('_key', fd.key);
            Session.putString('_secret', fd.secret);
            showInSnackBar('${fd.name}\'s domain is ${fd.domain}');
            fd.toString();
            int result = await db.add('INSERT INTO cloud(name, config) VALUES("${fd.domain}", "${fd.toString()}")');
            print("result $result");
        }
    }
    
    String _validateName(String value) {
        _formWasEdited = true;
        if (value.isEmpty)
            return 'Name is required.';
        final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
        if (!nameExp.hasMatch(value))
            return 'Please enter only alphabetical characters.';
        return null;
    }
    
    Future<bool> _warnUserAboutInvalidData() async {
        final FormState form = _formKey.currentState;
        if (form == null || !_formWasEdited || form.validate())
            return true;
        
        return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text('This form has errors'),
                    content: const Text('Really leave this form?'),
                    actions: <Widget> [
                        FlatButton(
                            child: const Text('YES'),
                            onPressed: () {
                                Navigator.of(context).pop(true);
                            },
                        ),
                        FlatButton(
                            child: const Text('NO'),
                            onPressed: () {
                                Navigator.of(context).pop(false);
                            },
                        ),
                    ],
                );
            },
        ) ?? false;
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: const Text('云端设置'),
            ),
            body: SafeArea(
                top: false,
                bottom: false,
                child: Form(
                    key: _formKey,
                    autovalidate: _autovalidate,
                    onWillPop: _warnUserAboutInvalidData,
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    initialValue:fd.name,
                                    validator: _validateName,
                                    onSaved: (String value) { fd.name = value; },
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Name *',
                                        suffixStyle: TextStyle(color: Colors.green),
                                        hintText: 'What do people call you?',
                                    ),
                                    maxLines: 1,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    initialValue:fd.key,
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) { fd.key = value; },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'AccessKey ID',
                                        //prefixText: '\$',
                                        //suffixText: 'USD',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 1,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    initialValue:fd.secret,
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) { fd.secret = value; },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Access Key Secret',
                                        //prefixText: '\$',
                                        //suffixText: 'USD',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 3,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    onSaved: (String value) { fd.domain = value; },
                                    keyboardType: TextInputType.number,
                                    initialValue:fd.domain,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Domain',
                                        prefixText: 'https://',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 2,
                                ),
                                
                                const SizedBox(height: 24.0),
                                Center(
                                    child: RaisedButton(
                                        child: const Text('提交'),
                                        onPressed: _handleSubmitted,
                                    ),
                                ),
                                const SizedBox(height: 24.0),
                                Text('* indicates required field',style: Theme.of(context).textTheme.caption ),
                                const SizedBox(height: 24.0),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

class FormData {
    String name = Session.getString('_name');
    String domain = Session.getString('_domain');
    String key = Session.getString('_key');
    String secret = Session.getString('_secret');
}


