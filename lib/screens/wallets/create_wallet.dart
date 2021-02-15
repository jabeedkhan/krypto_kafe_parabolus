import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:shimmer/shimmer.dart';

class CreateWallet extends StatefulWidget {
  final Function() notifyParent;

  CreateWallet({Key key, this.notifyParent}) : super(key: key);
  @override
  _CreateWalletState createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  var preferences = KryptoSharedPreferences();
  String name = "";
  UserData user;
  Utils utils = Utils();
  bool progressLoading = false, shimmerStatus = true;

  @override
  void initState() {
    super.initState();
    _intialize();
  }

  _intialize() async {
    try {
      user =
          UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
      setState(() {
        name = user.data.userName;
        shimmerStatus = false;
      });
    } catch (e) {}
  }

  makeWallet() async {
    var requestBody, jsonData;

    requestBody = {
      "user_id": user.data.id.toString().trim(),
    };

    try {
      var responseData =
          await http.post(HttpUrl.CREATE_WALLET, body: requestBody);
      if (responseData.statusCode == 200) {
        jsonData = jsonDecode(responseData.body);
        if (jsonData['error']) {
          setState(() {
            progressLoading = false;
          });
          utils.displayDialog(
              context: context, title: "", message: jsonData['message']);
        } else {
          user = UserData.fromJson(jsonData);
          preferences.save(StringConstants.USER_DATA, user);
          NewWallet wallet =
              NewWallet.fromJson(jsonData['data']['wyreResponse']);
          preferences.save(StringConstants.WALLET_DATA, wallet);
          setState(() {
            progressLoading = false;
          });
          widget.notifyParent();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: shimmerStatus
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[100],
                  highlightColor: Colors.grey[200],
                  enabled: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          visible: progressLoading,
                          child: LinearProgressIndicator(
                            minHeight: 8.0,
                          )),
                      Image.asset(
                        'assets/images/wallet_illustration.jpg',
                        height: mediaqueryHeight / 2.0,
                      ),

                      SizedBox(
                        height: mediaqueryHeight / 15.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 14.0),
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        width: mediaqueryWidth,
                        height: mediaqueryHeight / 10.0,
                        decoration: BoxDecoration(
                            //  color: Colors.blue,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Center(),
                      ),
                      //  Spacer(),
                      SizedBox(
                        height: mediaqueryHeight / 10.0,
                      ),
                      FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(hwSize / 30.0)),
                        padding: EdgeInsets.all(hwSize / 70.0),
                        color: Colors.blue,
                        onPressed: () {},
                        icon: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                        ),
                        label: Text("Create Wallet",
                            style: TextStyle(
                              fontSize: mediaqueryHeight / 45.0,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        visible: progressLoading,
                        child: LinearProgressIndicator(
                          minHeight: 8.0,
                        )),
                    Image.asset(
                      'assets/images/wallet_illustration.jpg',
                      height: mediaqueryHeight / 2.0,
                    ),

                    SizedBox(
                      height: mediaqueryHeight / 15.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 14.0),
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      width: mediaqueryWidth,
                      height: mediaqueryHeight / 10.0,
                      decoration: BoxDecoration(
                          //  color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Center(
                        child: Text(
                          "Hey $name, \nClick on the button below to create a Wallet to hold all your cryptocurrencies.",
                          style: TextStyle(
                              fontSize: mediaqueryHeight / 45.0,
                              color: Color(AppTheme.gray2),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    //  Spacer(),
                    SizedBox(
                      height: mediaqueryHeight / 10.0,
                    ),
                    RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(hwSize / 60.0)),
                      padding: EdgeInsets.symmetric(
                          vertical: mediaqueryHeight / 70.0,
                          horizontal: mediaqueryWidth / 10.0),
                      color: Colors.blue,
                      onPressed: () {
                        makeWallet();
                        setState(() {
                          progressLoading = true;
                        });
                      },
                      icon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                      ),
                      label: Text("Create Wallet",
                          style: TextStyle(
                            fontSize: mediaqueryHeight / 45.0,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
