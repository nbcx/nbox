import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'session.dart';
import 'sqlite.dart';
import 'dart:convert' show json;
import 'event_bus.dart';

class CloudSettingPage extends StatefulWidget {
    final int id;
    //final Map cloud;
    const CloudSettingPage({this.id,Key key });// : super(key: key)
    
    @override
    _CloudSettingPageState createState() => _CloudSettingPageState();
}

class _CloudSettingPageState extends State<CloudSettingPage> {
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    FormData fd = FormData();
    
    String _appTitle = '添加云端信息';
    bool isShowForm = false;//是否显示表单

    bool _autovalidate = false;
    bool _formWasEdited = false;

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        if(widget.id != null) {
            _update(widget.id);
        }
        else {
            setState(() {
                isShowForm = true;
            });
        }
    }
    
    Future<void> _update(int id) async{
        fd = FormData();
        Map cloud = await db.get('SELECT * FROM cloud WHERE id=?',[id]);
        fd.id = cloud['id'];
        Map config = json.decode(cloud['config']);
        print(config);
        _appTitle = "修改云端设置";
        fd.name = config['name'];
        fd.key = config['key'];
        fd.secret = config['secret'];
        fd.domain = config['domain'];
        setState(() {
            isShowForm = true;
        });
    }
    
    void showInSnackBar(String value) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(value)
        ));
    }
    
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
            if(fd.id > 0) {
                db.update('UPDATE cloud SET name = ?, config = ? WHERE id = ?',
                    [fd.name, fd.toJson(), fd.id]);
            }
            else {
                int result = await db.add('INSERT INTO cloud(name, config) VALUES(?,?)',[fd.name, fd.toJson()]);
                print("result $result");
            }
            bus.emit("changecloud", 1);
            showInSnackBar('${fd.name}\'s domain is ${fd.domain}');
            Navigator.of(context).pop(true);
        }
    }
    
    String _validateName(String value) {
        _formWasEdited = true;
        if (value.isEmpty)
            return 'Name is required.';
        //final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
        //if (!nameExp.hasMatch(value))
        //    return 'Please enter only alphabetical characters.';
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

    //表单视图
    Widget _form()  {
        //表单的初始值无法通过setState刷新，所以采用此方式
        if(isShowForm == false){
            return null;
        }
        return  Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                const SizedBox(height: 24.0),
                TextFormField(
                    initialValue: fd.name,
                    validator: _validateName,
                    onSaved: (String value) { fd.name = value; },
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
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
                        border: UnderlineInputBorder(),
                        labelText: 'AccessKey ID',
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
                        border: UnderlineInputBorder(),
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
                    keyboardType: TextInputType.text,
                    initialValue:fd.domain,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
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
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: Text(_appTitle),
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
                        child: _form(),
                    ),
                ),
            ),
        );
    }
}

class FormData {
    
    int id = 0;
    
    String name;
    String domain;
    String key;
    String secret;
    
    String toJson() {
        return json.encode({
            "name": name,
            "domain":domain,
            "key":key,
            "secret":secret,
        });
    }
}


