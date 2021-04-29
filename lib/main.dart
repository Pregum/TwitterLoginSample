import 'package:dart_twitter_api/twitter_api.dart' as TwiApi;
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
  /// SNSログイン側のプラグインのユーザーです。
  TwiLogin.User _authUser;
  AuthResult _authResult;

  /// Twitter API側のプラグインのユーザーです。
  /// こちらから紹介文やuser_idを取得しています。
  TwiApi.User _apiUser;

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
        final user = await _getUser(
            result.user.screenName, result.authToken, result.authTokenSecret);
        this.setState(() {
          _authUser = result.user;
          _authResult = result;
          _apiUser = user;
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

  Future<TwiApi.User> _getUser(
      String screenName, String oauthToken, String oauthTokenSecret) async {
    final twitterApi = TwiApi.TwitterApi(
      client: TwiApi.TwitterClient(
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
    print('user describe: ${user.description}');
    return user;
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
            if (_authUser != null) Text('email: ${_authUser.email}'),
            if (_authUser != null) Text('name: ${_authUser.name}'),
            if (_authUser != null) Text('screenName: ${_authUser.screenName}'),
            if (_authUser != null) Image.network('${_authUser.thumbnailImage}'),
            if (_authResult != null)
              Text('authToken: ${_authResult.authToken}'),
            if (_authResult != null)
              Text('authTokenSecret: ${_authResult.authTokenSecret}'),
            if (_apiUser != null) Text('userId: ${_apiUser.idStr}'),
            if (_apiUser != null) Text('description: ${_apiUser.description}'),
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
