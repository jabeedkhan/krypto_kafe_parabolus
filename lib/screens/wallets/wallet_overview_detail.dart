import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kryptokafe/screens/wallets/transfer/transfer_to_wallet.dart';
import 'package:kryptokafe/utils/enums.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/services.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'webview_container.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/customwidgets/nointernetconnection.dart';
import 'package:kryptokafe/screens/wallets/transfer/transfer_to_bank.dart';

class WalletOverviewDetail extends StatefulWidget {
  final List<CoinDetails> coinDetails;
  final index;
  WalletOverviewDetail(this.coinDetails, this.index);

  @override
  _WalletOverviewDetailState createState() => _WalletOverviewDetailState();
}

class _WalletOverviewDetailState extends State<WalletOverviewDetail> {
  String buttonText = "BUY NOW", depositAddress = "";
  var numberFormatter = NumberFormat('##,###.0#', 'en_US'),
      preferences = KryptoSharedPreferences(),
      coinName = "",
      coinSymbol = "",
      countryCode = "",
      availBalance = "";
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
    var requestBody, jsonData;
    String name = '';
    if (coinSymbol == "BTC") {
      name = 'bitcoin';
    } else {
      name = 'ethereum';
    }

    requestBody = {
      "sourceAmount": amountController.text.toString(),
      "country": countryCode,
      "sourceCurrency": "USD",
      "destCurrency": coinSymbol.toUpperCase(),
      "dest": "${name.toLowerCase()}:$depositAddress",
      "paymentMethod": "debit-card",
      "amountIncludeFees": "true",
      "redirectUrl": " ",
      "hideTrackBtn": "true"
    };

    try {
      var response = await http.post(
        HttpUrl.CHECKOUT,
        body: requestBody,
      );
      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        // amountController.clear();
        Navigator.pop(context);
        if (jsonData['error'] == "true") {
          utils.displayToast(jsonData['message'], context);
        } else {
          if (await canLaunch(jsonData['data']['url'])) {
            //handle return and call the api to check the updated wallet balance
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebviewContainer(
                  url: jsonData['data']['url'],
                ),
              ),
            ).then((value) => {lookUpWallet()});
          } else {
            throw 'Could not launch url';
          }
        }
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
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

          wallet.coinDetailList.forEach((element) {
            if (element.coinName == widget.coinDetails[widget.index].coinName) {
              setState(() {
                availBalance = element.balance.toString();
              });
            }
          });
        }
      } else {
        utils.displayToast(request.reasonPhrase, context);
      }
    } catch (e) {
      print(e);
    }
  }

  transferDialog(context) {
    return showDialog(
      context: context,
      child: AlertDialog(
          title: Center(child: Text('Transfer To')),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => TransferToWallet(
                            coinSymbol, userData, TransferType.wallet, ""),
                      ),
                    ).then((value) => lookUpWallet());
                  },
                  child: Text(
                    "Wallet",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BankTransfer(coinSymbol),
                      ),
                    );
                  },
                  child: Text(
                    "Bank",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  orderBottomSheet(context) {
    return showModalBottomSheet(
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
          body: internetStatus
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    sizedBox,
                    Text(
                      availBalance,
                      style: TextStyle(
                          fontSize: mediaqueryHeight / 25.0,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(coinSymbol),
                    sizedBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          onPressed: () {
                            // orderBottomSheet(context);
                            transferDialog(context);
                          },
                          child: Text(
                            "TRANSFER",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        ),
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
                            .whenComplete(() => utils.displayToast(
                                "copied to clipboard", context));
                      },
                    )
                    //tap to copy fuction
                  ],
                )
              : NoInternetConnection(),
        ),
      ),
    );
  }
}
