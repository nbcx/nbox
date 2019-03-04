import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _account = '';
  String _passWord = '';
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<FormState> _formKey = new GlobalKey();

  void _login(BuildContext context) async {
    // 关闭键盘
    FocusScope.of(context).requestFocus(new FocusNode());

    FormState form = _formKey.currentState;
    if (form.validate()) {
      // 保存表单
      form.save();

      // 显示Loading
      setState(() => _isLoading = true);

      // 关闭页面
      Navigator.of(context).pop();
      
    }
  }

  Widget _buildAppBar() => new AppBar(
      elevation: 0.0,
      leading: new IconButton(
          icon: new Icon(Icons.close),
          color: Colors.grey,
          onPressed: () => Navigator.of(context).pop()),
      backgroundColor: Colors.white);

  Widget _buildActionButton() => _isLoading
      ? new CircularProgressIndicator()
      : new FloatingActionButton(
          child: const Icon(Icons.send),
          onPressed: () => _login(context),
        );

  Widget _buildBody() {
    final Widget divider = new SizedBox(height: 32.0);

    return new Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32.0),
        child: new Column(children: <Widget>[
          // 标题
          const Text('图片盒子',style:const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
          divider,
          // 表单
          new Form(
            key: _formKey,
            child: new Column(children: <Widget>[
              // 账号输入框
              new TextFormField(
                  maxLines: 1,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: '登录账号'),
                  validator: (value) => value.isEmpty
                      ? '字段不能为空'
                      : null,
                  onSaved: (value) => this._account = value),

              divider,

              // 密码输入框
              new TextFormField(
                  maxLines: 1,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码'),
                  validator: (value) => value.isEmpty
                      ? '密码为空'
                      : null,
                  onSaved: (value) => this._passWord = value)
            ]),
          ),

          divider,

          // 登录按钮
          _buildActionButton()
        ]));
  }

  Widget build(BuildContext context) {
    final Widget appBar = _buildAppBar();

    final Widget body = _buildBody();

    return new Scaffold(key: _scaffoldKey, appBar: appBar, body: body);
  }
}
