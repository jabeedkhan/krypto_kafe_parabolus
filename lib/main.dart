import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/screens/home.dart';
import 'package:kryptokafe/screens/login_signup/login.dart';

import 'package:kryptokafe/screens/login_signup/update_screen.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/wyre/wyre_api.dart';
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          checkUserStatus();
        } else
          getData();
      }
    }
  }

  checkUserStatus() async {
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

        getData();
      }
    }
  }

  getData() async {
    try {
      var request = await http.get(HttpUrl.WDATA);
      if (request.statusCode == 200) {
        var jsonData = jsonDecode(request.body);
        preferences
          ..setString(WyreApi.AAPI__KEY, jsonData['data']['apiKey'])
          ..setString(WyreApi.SECRET_KEY, jsonData['data']['secretKey']);
        if (userData.data != null && userData.data.walletStatus == 1) {
          lookUpWallet();
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => loginStatus == "1" ? Home() : Login()));
        }
      } else {
        utils.displayToast("Something went wrong, we're fixing it", context);
      }
    } catch (e) {}
  }

  lookUpWallet() async {
    var url;
    try {
      url =
          "${WyreApi.WYRE_BASE}v2/wallet/${userData.data.walletId}?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
      var request = await http.get(
        url,
        headers: {
          "X-Api-Key": await preferences.getString(WyreApi.AAPI__KEY),
          "X-Api-Signature": await utils.signature(url: url)
        },
      );

      if (request.statusCode == 200) {
        NewWallet wallet = NewWallet.fromJson(jsonDecode(request.body));
        preferences.save(StringConstants.WALLET_DATA, wallet);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => loginStatus == "1" ? Home() : Login()));
      } else {
        utils.displayToast(request.reasonPhrase, context);
      }
    } catch (e) {
      print(e);
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
