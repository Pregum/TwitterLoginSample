import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/entity/user.dart';
import 'package:twitter_login/twitter_login.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter認証サンプル',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Twitter認証サンプル'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User _user;
  AuthResult _authResult;

  Future _loginTwitter() async {
    final twitterLogin = TwitterLogin(
        apiKey: DotEnv().env['CONSUMER_KEY'],
        apiSecretKey: DotEnv().env['CONSUMER_SECRET_KEY'],
        redirectURI: 'example://');

    final AuthResult result = await twitterLogin.login();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        print('login success!');
        this.setState(() {
          _user = result.user;
          _authResult = result;
        });
        break;
      case TwitterLoginStatus.cancelledByUser:
        print('cancel login');
        break;
      case TwitterLoginStatus.error:
        print('login error!!11!');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_user != null) Text('email: ${_user.email}'),
            if (_user != null) Text('name: ${_user.name}'),
            if (_user != null) Text('screenName: ${_user.screenName}'),
            if (_user != null) Image.network('${_user.thumbnailImage}'),
            if (_authResult != null)
              Text('authToken: ${_authResult.authToken}'),
            if (_authResult != null)
              Text('authTokenSecret: ${_authResult.authTokenSecret}'),
            RaisedButton(
              child: Text('Twitter認証でログイン'),
              onPressed: _loginTwitter,
            ),
          ],
        ),
      ),
    );
  }
}
