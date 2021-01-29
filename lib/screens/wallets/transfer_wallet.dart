import 'dart:convert';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/services.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/utils/assets.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:kryptokafe/wyre/wyre_api.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'webview_container.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/model/user_data.dart';

class TransferWallet extends StatefulWidget {
  final List<CoinDetails> coinDetails;
  final index;

  TransferWallet(this.coinDetails, this.index);

  @override
  _TransferWalletState createState() => _TransferWalletState();
}

class _TransferWalletState extends State<TransferWallet> {
  String buttonText = "BUY NOW", depositAddress = "";
  var numberFormatter = NumberFormat('##,###.0#', 'en_US'),
      preferences = KryptoSharedPreferences(),
      coinName = "",
      coinSymbol = "",
      countryCode = "",
      availBalance;
  TextEditingController amountController = TextEditingController();
  Utils utils = Utils();
  bool buttonEnabled = false;
  bool internetStatus = true, shimmerStatus = true;
  Connectivity connectivity = Connectivity();
  UserData userData;

  onInternetStatus(value) {
    if (value == ConnectivityResult.mobile ||
        value == ConnectivityResult.wifi) {
      setState(() {
        internetStatus = true;
      });
    } else {
      setState(() {
        internetStatus = false;
      });
    }
  }

  walletOrderReservation() async {
    FocusScope.of(context).unfocus();
    var url, requestBody, jsonData;
    url = WyreApi.WYRE_BASE +
        "v3" +
        "/orders/reserve?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";

    requestBody = {
      "sourceAmount": amountController.text.toString(),
      "country": countryCode,
      "sourceCurrency": "USD",
      "destCurrency": coinSymbol.toUpperCase(),
      "dest": "${coinName.toLowerCase()}:$depositAddress",
      "paymentMethod": "debit-card",
      "amountIncludeFees": true,
      "referrerAccountId": "AC_8688GQ2B4QE", //LIVE ACCOUNT
      // "referrerAccountId": "AC_E98CBUNEZCE", // TEST ACCOUNT
      "redirectUrl":
          "https://www.salesmerger.com" // TODO change redirect URL find a solution for this
    };
    var jsonBody = jsonEncode(requestBody);
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Api-Key": await preferences.getString(WyreApi.AAPI__KEY),
          "X-Api-Signature": await utils.signature(url: url, data: jsonBody)
        },
        body: jsonBody,
      );
      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        // amountController.clear();
        Navigator.pop(context);

        if (await canLaunch(jsonData['url'])) {
          //write a function to handle return and call the api to check the transfer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebviewContainer(
                url: jsonData['url'],
              ),
            ),
          ).then((value) => {lookUpWallet()});
        } else {
          throw 'Could not launch $url';
        }
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  lookUpWallet() async {
    var url;
    var userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));

    try {
      url = WyreApi.WYRE_BASE +
          "v2" +
          WyreApi.WALLETS +
          "/${userData.data.walletId}" +
          "?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
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

        wallet.coinDetailList.forEach((element) {
          if (element.coinName == widget.coinDetails[widget.index].coinName) {
            setState(() {
              availBalance = element.balance.toString();
            });
          }
        });
      } else {
        utils.displayToast(request.reasonPhrase, context);
      }
    } catch (e) {
      print(e);
    }
  }

  orderBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext cntxt) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('Enter the amount you want to purchase for'),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Spacer(),
                        Container(
                          width: 100.0,
                          //  padding: EdgeInsets.all(15.0),
                          child: TextField(
                            controller: amountController,
                            showCursor: false,
                            // cursorWidth: 0.0,
                            textAlign: TextAlign.center,
                            maxLength: 5,
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '0',
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              if (int.parse(val) > 9)
                                setModalState(() {
                                  buttonEnabled = true;
                                });
                              else if (int.parse(val) < 10)
                                setModalState(() {
                                  buttonEnabled = false;
                                });
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Text(
                          "\$",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 26.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    FlatButton(
                      disabledColor: Colors.grey,
                      minWidth: 200.0,
                      child: Text(
                        buttonText,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: buttonEnabled
                          ? () {
                              setModalState(() {
                                buttonText = "CREATING ORDER";
                              });
                              if (internetStatus)
                                walletOrderReservation();
                              else
                                utils.displayDialog(
                                    context: context,
                                    message:
                                        "Please check your network connection",
                                    title: "");
                            }
                          : null,
                      color: Colors.lightBlue,
                    ),
                    Text("Purchase includes fee: \$5 minimum or 2.9% to 3.9%.")
                  ],
                ),
              );
            },
          );
        }).whenComplete(() => setState(() {
          buttonText = "BUY NOW";
        }));
  }

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    _initialize();
  }

  _initialize() async {
    userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
    setState(() {
      countryCode = userData.data.userCountryCode;
      availBalance = widget.coinDetails[widget.index].balance.toString();
      depositAddress = widget.coinDetails[widget.index].address.toString();
      coinName = widget.coinDetails[widget.index].coinName;
      coinSymbol = widget.coinDetails[widget.index].coinSymbol.toUpperCase();
    });
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;
    var sizedBox = SizedBox(
      height: mediaqueryHeight / 80,
    );

    return WillPopScope(
      onWillPop: () => _willPopCallback(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              coinName,
              style: TextStyle(color: Colors.black),
            ),
            leading: BackButton(
              color: Colors.black,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              sizedBox,
              Text(
                availBalance,
                style: TextStyle(
                    fontSize: mediaqueryHeight / 35.0,
                    fontWeight: FontWeight.w600),
              ),
              Text(coinSymbol),
              sizedBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // FlatButton(
                  //   onPressed: () {},
                  //   child: Text(
                  //     "SEND",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   color: Colors.blue,
                  // ),
                  FlatButton(
                    onPressed: () {
                      orderBottomSheet(context);
                    },
                    child: Text(
                      "BUY",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  ),
                  // FlatButton(
                  //   onPressed: () {},
                  //   child: Text(
                  //     "Copy",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   color: Colors.blue,
                  // ),
                ],
              ),
              Divider(
                height: 2.0,
              ),
              SizedBox(
                height: mediaqueryHeight / 20.0,
              ),
              QrImage(
                data: depositAddress,
                version: QrVersions.auto,
                size: hwSize / 5.0,
              ),
              sizedBox,
              Text(
                depositAddress,
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.start,
              ),
              FlatButton(
                child: Text("Tap to copy"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: depositAddress))
                      .whenComplete(() =>
                          utils.displayToast("copied to clipboard", context));
                },
              )
              //tap to copy fuction
            ],
          ),
        ),
      ),
    );
  }
}
