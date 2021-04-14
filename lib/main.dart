import 'package:dart_twitter_api/twitter_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/entity/user.dart' as TwiLogin;
import 'package:twitter_login/twitter_login.dart';

import 'package:http/http.dart' as http;

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
  TwiLogin.User _user;
  AuthResult _authResult;

  String _userId;

  Future _loginTwitter() async {
    final twitterLogin = TwitterLogin(
        apiKey: DotEnv().env['CONSUMER_KEY'],
        apiSecretKey: DotEnv().env['CONSUMER_SECRET_KEY'],
        redirectURI: 'example://');

    final AuthResult result = await twitterLogin.login();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        print('login success!');
        print('oauthToken: ${result.authToken}');
        print('oauthTokenSecret: ${result.authTokenSecret}');
        final userId = await _getUserId(
            result.user.screenName, result.authToken, result.authTokenSecret);
        this.setState(() {
          _user = result.user;
          _authResult = result;
          _userId = userId;
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

  Future<String> _getUserId(
      String screenName, String oauthToken, String oauthTokenSecret) async {
    final twitterApi = TwitterApi(
      client: TwitterClient(
        consumerKey: DotEnv().env['CONSUMER_KEY'],
        consumerSecret: DotEnv().env['CONSUMER_SECRET_KEY'],
        token: oauthToken,
        secret: oauthTokenSecret,
      ),
    );

    final user = await twitterApi.userService.usersShow(
      screenName: screenName,
      includeEntities: false,
    );
    print('userId: ${user.idStr}');
    print('user info: ${user.toJson()}');
    return user.idStr;
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
            if (_userId != null) Text('userId: $_userId'),
            ElevatedButton(
              child: Text('Twitter認証でログイン'),
              onPressed: _loginTwitter,
            ),
          ],
        ),
      ),
    );
  }

  // String _fetchUserId(
  //     String screenName, String oauthToken, String oauthTokenSecret) {
  //   Uri endPoint = Uri.https(
  //       'api.twitter.com', '1.1/users/show.json', {'screen_name': screenName});
  //   Map<String, String> header = {
  //     'authorization': 'OAuth'
  //   };

  //   http.get(
  //     endPoint.toString(),
  //   );
  // }
}
