import 'dart:convert';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:kryptokafe/wyre/wyre_api.dart';
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
  var perferences = KryptoSharedPreferences();
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
          UserData.fromJson(await perferences.read(StringConstants.USER_DATA));
      setState(() {
        name = user.data.userName;
        shimmerStatus = false;
      });
    } catch (e) {}
  }

  makeWallet() async {
    var url, requestBody, jsonData;
    try {
      url = WyreApi.WYRE_BASE +
          "v2" +
          WyreApi.WALLETS +
          "?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
      // url =
      //     "https://api.testwyre.com/v2/wallets?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
      requestBody = {
        "name": user.data.uniqueString,
        "type": "SAVINGS",
      };

      var jsonBody = jsonEncode(requestBody);

      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "X-Api-Key": await perferences.getString(WyreApi.AAPI__KEY),
            "X-Api-Signature": await utils.signature(url: url, data: jsonBody)
          },
          body: jsonBody);

      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        NewWallet wallet = NewWallet.fromJson(jsonData);
        perferences.save("wallet", wallet);
        setState(() {
          progressLoading = false;
        });
        widget.notifyParent();
      } else if (response.statusCode == 400) {
        jsonData = jsonDecode(response.body);
        utils.displayDialog(
            context: context, title: "", message: jsonData['message']);
      }

      setState(() {
        progressLoading = false;
      });
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
