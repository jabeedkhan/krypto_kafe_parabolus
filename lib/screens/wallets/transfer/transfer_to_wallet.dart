import 'dart:convert';
import 'package:currency_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/http_url.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'confirm_transfer.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/customwidgets/nointernetconnection.dart';
import 'package:kryptokafe/utils/enums.dart';
import 'package:flutter/services.dart';

class TransferToWallet extends StatefulWidget {
  /// Using the same functionality to both Wallet and Bank Transfer using [TransferType] enum value
  final coinCode;
  final UserData userData;
  final transferType;
  final paymentId;
  TransferToWallet(
      this.coinCode, this.userData, this.transferType, this.paymentId);

  @override
  _TransferToWalletState createState() => _TransferToWalletState();
}

class _TransferToWalletState extends State<TransferToWallet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(),
      _messageController = TextEditingController(),
      _adressController = TextEditingController();
  List<String> walletDropDownList;
  String selectedWallet,
      walletType,
      currenySymbol,
      hintText,
      addressSRN,
      addressType,
      message = '',
      address,
      amount;
  double exchnageCurrencyValue = 0.0;
  Country country;
  var jsonData;
  Connectivity connectivity = Connectivity();
  bool internetStatus = true, loadingProgress = false;

  @override
  void initState() {
    _initialize();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    super.initState();
  }

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

  _initialize() {
    selectedWallet = 'Wyre Wallet Address';
    walletType = StringConstants.W2W;
    getExchangePairValue();

    /// [currenySymbol] has to be USD if bank transfer
    currenySymbol = widget.transferType == TransferType.wallet
        ? NumberFormat.simpleCurrency(
                name: widget.userData.data.userCurrencyCode)
            .currencySymbol
        : NumberFormat.simpleCurrency(name: "USD").currencySymbol;

    if (widget.coinCode == "BTC") {
      walletDropDownList = ['Wyre Wallet Address', 'Bitcoin Address'];
    } else {
      walletDropDownList = ['Wyre Wallet Address', 'Ethereum Address'];
    }
    checkWalletType();
  }

  getExchangePairValue() async {
    var response = await http.get(HttpUrl.EXCHANGE_RATES);
    if (response.statusCode == 200) {
      jsonData = jsonDecode(response.body);

      calculateAmountValue();
    }
  }

  calculateAmountValue() {
    double userAmount, marketValue;
    try {
      userAmount = double.tryParse(_amountController.text.trim().toString());
      if (widget.transferType == TransferType.wallet) {
        marketValue = jsonData[
                '${widget.coinCode + widget.userData.data.userCurrencyCode}']
            [widget.userData.data.userCurrencyCode];
      } else if (widget.transferType == TransferType.bank) {
        marketValue = double.tryParse(
            jsonData['${widget.coinCode + "USD"}']["USD"].toString());
      }

      if (_amountController.text.trim().toString().isNotEmpty) {
        setState(() {
          exchnageCurrencyValue = (userAmount * marketValue);
        });
      } else {
        setState(() {
          exchnageCurrencyValue = 0.0;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  checkWalletType() {
    switch (selectedWallet) {
      case 'Bitcoin Address':
        hintText = "Enter a BTC address";
        addressSRN = "bitcoin";
        walletType = StringConstants.W2E;
        break;
      case 'Ethereum Address':
        hintText = "Enter a ETH address";
        addressSRN = "ethereum";
        walletType = StringConstants.W2E;
        break;

      case 'Wyre Wallet Address':
        hintText = "Enter Wyre wallet address";
        addressSRN = "wallet";
        walletType = StringConstants.W2W;
        break;

      default:
    }
  }

  createTransfer() async {
    var requestBody = {}, mapData = {}, jsonData;
    if (selectedWallet == "Wyre Wallet Address") {
      address = address.toUpperCase();
    }
    try {
      if (widget.transferType == TransferType.wallet) {
        mapData = {
          "destCurrency": widget.coinCode,
          "dest": addressSRN + ":" + address,
          "transfer_type": StringConstants.W2W,
        };
      } else if (widget.transferType == TransferType.bank) {
        mapData = {
          "destCurrency": "USD",
          "dest": "paymentmethod:${widget.paymentId}",
          "transfer_type": StringConstants.W2B,
        };
      }

      requestBody = {
        "user_id": widget.userData.data.id,
        "source": "wallet:${widget.userData.data.walletId}",
        "sourceCurrency": widget.coinCode,
        "destAmount": amount,
        "message": message,
        "autoConfirm": false,
        "payment_id": widget.paymentId
      };

      requestBody.addAll(mapData);

      var response = await http.post(HttpUrl.CREATE_TRANSFER,
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          loadingProgress = false;
        });
        jsonData = jsonDecode(response.body);
        if (jsonData['error'] == "false") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmTransfer(jsonData),
            ),
          );
        } else {
          Utils().displayToast(jsonData['message'], context);
        }
      } else {
        Utils().displayToast(response.reasonPhrase, context);
        setState(() {
          loadingProgress = false;
        });
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
    var sizedBox = SizedBox(
      height: mediaqueryHeight / 20,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Color(AppTheme.gray2),
        ),
        centerTitle: true,
        title: Text(
          "Wallet Transfer",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: internetStatus
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: [
                      loadingProgress ? LinearProgressIndicator() : SizedBox(),
                      TextFormField(
                        controller: _amountController,
                        maxLengthEnforced: true,
                        showCursor: false,
                        // cursorWidth: 0.0,
                        textAlign: TextAlign.center,
                        maxLength: 10,
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(new RegExp('[ -,]'))
                        ],
                        decoration: InputDecoration(
                          prefixText: widget.coinCode,
                          prefixStyle: TextStyle(fontSize: 20.0),
                          counterText: '',
                          hintText: '0',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          // value = "${Utils().formatNumber(value.replaceAll(",", ''))}";
                          // _amountController.value = TextEditingValue(
                          //   text: value,
                          //   selection: TextSelection.collapsed(offset: value.length),
                          // );
                          calculateAmountValue();
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Field cannot be empty';
                          }
                          return null;
                        },
                      ),
                      sizedBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(currenySymbol,
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w600)),
                          SizedBox(width: 10.0),
                          Text(exchnageCurrencyValue.toStringAsFixed(3),
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      sizedBox,
                      Visibility(
                        visible: widget.transferType == TransferType.wallet
                            ? true
                            : false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Receiver Address Type",
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(AppTheme.gray7),
                                  borderRadius: BorderRadius.circular(5.0)),
                              padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              child: DropdownButton<String>(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  value: selectedWallet,
                                  underline: Container(
                                    height: 0,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: walletDropDownList.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedWallet = newValue;
                                    });
                                    checkWalletType();
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.transferType == TransferType.wallet
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _adressController,
                            decoration: InputDecoration(hintText: hintText),
                            validator: (string) {
                              if (string.isEmpty) {
                                return 'Field cannot be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _messageController,
                          decoration:
                              InputDecoration(hintText: "Message (optional)"),
                        ),
                      ),
                      sizedBox,
                      FlatButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            address = _adressController.text.toString();
                            message = _messageController.text.toString();
                            amount = _amountController.text.toString();
                            FocusScope.of(context).unfocus();
                            setState(() {
                              loadingProgress = true;
                            });
                            createTransfer();
                          }
                        },
                        child: Text(
                          "SEND",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : NoInternetConnection(),
    );
  }
}
