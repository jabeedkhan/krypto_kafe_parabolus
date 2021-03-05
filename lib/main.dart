import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/screens/home.dart';
import 'package:kryptokafe/screens/login_signup/login.dart';

import 'package:kryptokafe/screens/login_signup/update_screen.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:connectivity/connectivity.dart';
import 'model/new_wallet.dart';

void main() {
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krypto Kafe',
      theme: ThemeData(
        fontFamily: StringConstants.oxygenFontnameString,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();
  var utils = Utils();
  var userId, loginStatus;
  PackageInfo packageInfo;
  var preferences = KryptoSharedPreferences();
  UserData userData = UserData();
  bool internetStatus = true, shimmerStatus = true;
  Connectivity connectivity = Connectivity();

  onInternetStatus(value) {
    if (value == ConnectivityResult.mobile ||
        value == ConnectivityResult.wifi) {
      if (mounted)
        setState(() {
          internetStatus = true;
        });
      checkAppUpdate();
    } else {
      if (mounted)
        setState(() {
          internetStatus = false;
        });
      utils.displayToast('Please check your network connection', context);
    }
  }

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    var initializationAndroidSetting =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    var initalizationSettingIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationAndroidSetting, iOS: initalizationSettingIOS);

    flutterLocalNotifications.initialize(initializationSettings,
        onSelectNotification: onSelectNotifications);
    _firebaseMessaging.getToken().then((value) => print(value));
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        return showNotifications(message);
      },
    );
  }

  Future onSelectNotifications(String payload) async {
    print(payload);
    showDialog(
      context: navigatorKey.currentContext,
      builder: (_) => AlertDialog(
        title: Text("Here is your payload"),
        content: Text("Payload"),
      ),
    );
  }

  showNotifications(Map<String, dynamic> message) {
    var android = AndroidNotificationDetails(
        'channel_id', "CHANNEL NAME", "Channel description");
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    flutterLocalNotifications.show(0, message['notification']['title'],
        message['notification']['body'], platform,
        payload: message["data"]['payload']);
  }

  checkAppUpdate() async {
    var preferences = KryptoSharedPreferences();
    packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    loginStatus =
        await preferences.getString(StringConstants.LOGIN_STATUS) ?? "0";

    if (loginStatus.contains("1"))
      userData =
          UserData.fromJson(await preferences.read(StringConstants.USER_DATA));

    var jsonData;

    try {
      var request = await http.post(HttpUrl.APP_UPDATE, body: {
        "platform": Platform.isAndroid ? "android" : "ios",
        "versionDetails": version.toString()
      });
      if (request.statusCode == 200) {
        jsonData = jsonDecode(request.body);
        if (jsonData["error"]) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateScreen(
                        url: jsonData["data"],
                      )));
        } else {
          if (userData.data != null) {
            getUserDetails();
          } else
            checkWalletStatus();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  getUserDetails() async {
    var jsonData;
    var request = await http.post(HttpUrl.USER_STATUS,
        body: {"userId": userData.data.id.toString()});

    if (request.statusCode == 200) {
      jsonData = jsonDecode(request.body);
      if (jsonData["error"]) {
        utils.displayToast(jsonData["message"], context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        UserData userData = UserData.fromJson(jsonData);
        preferences.save(StringConstants.USER_DATA, userData);

        checkWalletStatus();
      }
    }
  }

  checkWalletStatus() async {
    if (userData.data != null && userData.data.walletStatus == 1) {
      lookUpWallet();
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => loginStatus == "1" ? Home(1) : Login()));
    }
  }

  lookUpWallet() async {
    try {
      var request = await http.post(HttpUrl.LOOKUP_WALLET,
          body: {"user_id": userData.data.id.toString()});

      if (request.statusCode == 200) {
        var jsonBody = jsonDecode(request.body);

        if (!jsonBody['error']) {
          NewWallet wallet = NewWallet.fromJson(jsonBody['data']);
          preferences.save(StringConstants.WALLET_DATA, wallet);
        }

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => loginStatus == "1" ? Home(1) : Login()));
      } else {
        utils.displayToast(request.reasonPhrase, context);
      }
    } catch (e) {
      print("LOOK UP WALLET $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  "Krypto Kafe".toUpperCase(),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 20.0,
                    color: Colors.black,
                    fontFamily: StringConstants.oxygenFontnameString,
                  ),
                ),
              ),
            ),
            utils.progressIndicator(),
            // Image.asset(
            //   "assets/images/shroak_landscape_logo.png",
            //   scale: 15.0,
            // )
            Text(
              "Powered By",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 55.0,
                color: Colors.black,
                fontFamily: StringConstants.oxygenFontnameString,
              ),
            ),
            Text(
              "Parabolus Inc.",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40.0,
                color: Colors.black,
                fontFamily: StringConstants.oxygenFontnameString,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
