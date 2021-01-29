import 'dart:convert';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/screens/wallets/create_wallet.dart';
import 'package:kryptokafe/screens/wallets/wallet_overview.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WalletFragmentContainer extends StatefulWidget {
  @override
  _WalletFragmentContainerState createState() =>
      _WalletFragmentContainerState();
}

class _WalletFragmentContainerState extends State<WalletFragmentContainer> {
  int userType;
  var preferences = KryptoSharedPreferences();
  UserData userData;
  bool showLoading = true;
  Utils utils = Utils();

  @override
  void initState() {
    super.initState();
    _intialize();
    // changeValue();
    //check from the userData to chec o userTyepe
  }

  _intialize() async {
    userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
    setState(() {
      userType = userData.data.walletStatus;
      showLoading = false;
    });
  }

  changeValue() async {
    var jsonData;
    NewWallet wallet =
        NewWallet.fromJson(await preferences.read(StringConstants.WALLET_DATA));
    var requestBody = {
      "user_id": userData.data.id.toString().trim(),
      "wallet_id": wallet.id
    };
    //  print(requestBody);

    try {
      var responseData =
          await http.post(HttpUrl.SEND_WALLET, body: requestBody);
      if (responseData.statusCode == 200) {
        jsonData = jsonDecode(responseData.body);
        if (jsonData['error']) {
          //  print(jsonData['message']);
          utils.displayToast(jsonData['message'], context,
              gravity: ToastGravity.CENTER);
        } else {
          userData = UserData.fromJson(jsonData);
          preferences.save(StringConstants.USER_DATA, userData);
          setState(() {
            userType = 1;
            showLoading = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return showLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userType == 0
            ? CreateWallet(notifyParent: changeValue)
            : WalletOverview();
  }
}
