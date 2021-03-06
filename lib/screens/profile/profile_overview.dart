import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/screens/login_signup/login.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/screens/profile/transfer_history.dart';

class ProfileOverview extends StatefulWidget {
  @override
  _ProfileOverviewState createState() => _ProfileOverviewState();
}

class _ProfileOverviewState extends State<ProfileOverview> {
  var preferences = KryptoSharedPreferences();
  String name = "",
      email = "",
      accountStatus = "",
      walletId = "",
      userCountryName = "";
  UserData user;
  NewWallet wallet;

  @override
  void initState() {
    super.initState();
    _intitalize();
  }

  _intitalize() async {
    try {
      user =
          UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
      setState(() {
        name = user.data.userName;
        email = user.data.userEmail;
        userCountryName = user.data.userCountryName;
      });
      if (user.data.walletStatus == 1) {
        wallet = NewWallet.fromJson(
            await preferences.read(StringConstants.WALLET_DATA));
        setState(() {
          walletId = wallet.id;
        });
      } else {
        setState(() {
          walletId = "No wallet created";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  logout() {
    preferences.remove("user");
    if (user.data.walletStatus == 1)
      preferences.remove(StringConstants.WALLET_DATA);
    preferences.setString(StringConstants.LOGIN_STATUS, "0");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    // var mediaqueryWidth = MediaQuery.of(context).size.width;
    // var hwSize = mediaqueryHeight + mediaqueryWidth;
    var sizedBox = SizedBox(
      height: mediaqueryHeight / 80,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Name : $name",
                  style: TextStyle(fontSize: mediaqueryHeight / 45.0),
                ),
              ),
              sizedBox,
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Email : $email",
                  style: TextStyle(fontSize: mediaqueryHeight / 45.0),
                ),
              ),
              sizedBox,
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text("Country : $userCountryName",
                    style: TextStyle(fontSize: mediaqueryHeight / 45.0)),
              ),
              sizedBox,
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text("Wallet ID : $walletId",
                    style: TextStyle(fontSize: mediaqueryHeight / 45.0)),
              ),
              sizedBox,
              Divider(
                indent: 30.0,
                endIndent: 30.0,
                height: 3.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Colors.blue,
                ),
                trailing:
                    Icon(Icons.chevron_right_outlined, color: Colors.black),
                title: Text("Transaction History",
                    style: TextStyle(fontSize: mediaqueryHeight / 45.0)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransferHistory()));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.blue,
                ),
                trailing:
                    Icon(Icons.chevron_right_outlined, color: Colors.black),
                title: Text("Logout",
                    style: TextStyle(fontSize: mediaqueryHeight / 45.0)),
                onTap: () {
                  logout();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
