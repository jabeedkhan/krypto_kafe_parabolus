import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/screens/wallets/create_wallet.dart';
import 'package:kryptokafe/screens/wallets/wallet_list.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/utils.dart';

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
    //  print(requestBody);

    userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));

    setState(() {
      userType = userData.data.walletStatus;
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userType == 0
            ? CreateWallet(notifyParent: changeValue)
            : WalletList();
  }
}
