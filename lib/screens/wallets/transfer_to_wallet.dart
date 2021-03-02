import 'dart:convert';
import 'package:currency_pickers/country.dart';
import 'package:currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/http_url.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/utils/utils.dart';

class TransferToWallet extends StatefulWidget {
  final coinCode;
  final UserData userData;
  TransferToWallet(this.coinCode, this.userData);

  @override
  _TransferToWalletState createState() => _TransferToWalletState();
}

class _TransferToWalletState extends State<TransferToWallet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(),
      _messageController = TextEditingController(),
      _adressController = TextEditingController();
  List<String> walletType;
  String selectedWallet,
      symbol,
      hintText,
      addressSRN,
      addressType,
      message = '',
      address,
      amount;
  double exchnageCurrencyValue = 0.0;
  Country country;
  var jsonData;

  @override
  void initState() {
    getExchangePairValue();
    symbol =
        NumberFormat.simpleCurrency(name: widget.userData.data.userCurrencyCode)
            .currencySymbol;
    selectedWallet = 'Wyre Wallet Address';

    _initialize();
    super.initState();
  }

  _initialize() {
    if (widget.coinCode == "BTC") {
      walletType = ['Wyre Wallet Address', 'Bitcoin Address'];
    } else {
      walletType = ['Wyre Wallet Address', 'Ethereum Address'];
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
    double userAmount =
            double.tryParse(_amountController.text.trim().toString()),
        marketValue = jsonData[
                '${widget.coinCode + widget.userData.data.userCurrencyCode}']
            [widget.coinCode];

    if (_amountController.text.trim().toString().isNotEmpty) {
      setState(() {
        exchnageCurrencyValue = (userAmount * marketValue);
      });
    } else {
      setState(() {
        exchnageCurrencyValue = 0.0;
      });
    }
  }

  checkWalletType() {
    switch (selectedWallet) {
      case 'Bitcoin Address':
        hintText = "Enter a BTC address";
        addressSRN = "bitcoin";
        break;
      case 'Ethereum Address':
        hintText = "Enter a ETH address";
        addressSRN = "ethereum";
        break;

      case 'Wyre Wallet Address':
        hintText = "Enter Wyre wallet address";
        addressSRN = "wallet";
        break;

      default:
    }
  }

  createTransfer() async {
    var requestBody, jsonData;

    try {
      requestBody = {
        "user_id": widget.userData.data.id,
        "source": "wallet:${widget.userData.data.walletId}",
        "sourceCurrency": widget.coinCode,
        "destAmount": amount,
        "destCurrency": widget.coinCode,
        "dest": addressSRN + ":" + address,
        "message": message,
        "autoConfirm": false,
        "transfer_type": "",
        "payment_id": ""
      };
      print(jsonEncode(requestBody));

      var response = await http.post(HttpUrl.CREATE_TRANSFER,
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        if (jsonData['error'] == "false") {
          print(jsonData.toString());
        } else {
          Utils().displayToast(jsonData['message'], context);
        }
      }

      print(jsonEncode(requestBody));
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _amountController,
                  maxLengthEnforced: true,
                  showCursor: false,
                  // cursorWidth: 0.0,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: TextStyle(

                    
                    fontSize: 45.0,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: symbol,
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
                    if (val.isNotEmpty) {
                      if (double.tryParse(val) < 1.0) {
                        return 'Please enter a minimum value';
                      }
                    } else {
                      return 'Field cannot be empty';
                    }
                    return null;
                  },
                ),
                sizedBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.coinCode,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w600)),
                    SizedBox(width: 10.0),
                    Text(exchnageCurrencyValue.toStringAsFixed(3),
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w600)),
                  ],
                ),
                sizedBox,
                Row(
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
                          items: walletType.map((String value) {
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
                Padding(
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
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Message (optional)"),
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
      ),
    );
  }
}
