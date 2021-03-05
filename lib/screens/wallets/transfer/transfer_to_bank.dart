import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:kryptokafe/customwidgets/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/model/state_codes.dart';
import 'package:kryptokafe/utils/assets.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:kryptokafe/screens/wallets/transfer/transfer_to_wallet.dart';
import 'package:kryptokafe/utils/enums.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/utils.dart';

class BankTransfer extends StatefulWidget {
  final coinSymbol;
  BankTransfer(this.coinSymbol);
  @override
  _BankTransferState createState() => _BankTransferState();
}

class _BankTransferState extends State<BankTransfer> {
  final _bankFormKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  TextEditingController firstNameController = TextEditingController(),
      lastNameController = TextEditingController(),
      addressController = TextEditingController(),
      addressController2 = TextEditingController(),
      postalController = TextEditingController(),
      phoneNumberController = TextEditingController(),
      accountController = TextEditingController(),
      routingController = TextEditingController();
  DateTime selectedDate;
  bool isChanged = true, showDobError = false;
  UsStates selectedState;
  List<String> cityList = [];
  List<UsStates> usStateList = [];
  String selectedCity,
      beneficiaryType,
      routingNumber,
      accountType,
      paymentMethodId;
  KryptoSharedPreferences preferences = KryptoSharedPreferences();
  UserData userData;
  bool loadingProgress = false;

  openDatePicker() async {
    FocusScope.of(context).unfocus();

    final DateTime picked = await showDatePicker(
        initialDatePickerMode: DatePickerMode.day,
        initialEntryMode: DatePickerEntryMode.calendar,
        context: context,
        firstDate: DateTime(DateTime.now().year - 100, 1),
        initialDate: selectedDate == null
            ? DateTime(DateTime.now().year - 18, 1, 1)
            : selectedDate,
        lastDate: DateTime(DateTime.now().year - 18, 12, 31),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData(primarySwatch: Colors.red), child: child);
        });

    if (picked != null && picked != selectedDate)
      setState(() {
        isChanged = true;
        selectedDate = picked;
        showDobError = false;
      });
  }

  @override
  void initState() {
    _initialize();

    super.initState();
  }

  _initialize() async {
    beneficiaryType = "INDIVIDUAL";
    accountType = "CHECKING";
    usStateList = UsStates().getStateList();
    var list = usStateList;
    selectedState = list[0];

    if (selectedState != null)
      cityList = Assets().statesAndCities[selectedState.stateName];
    selectedCity = cityList[0];

    userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
  }

  createPayment() async {
    var requestbody = {}, jsonData;
    requestbody = {
      "user_id": userData.data.id.toString(),
      "transfer_type": StringConstants.W2B,
      "paymentMethodType": "INTERNATIONAL_TRANSFER",
      "paymentType": "LOCAL_BANK_WIRE",
      "currency": "USD",
      "country": "US",
      "beneficiaryType": beneficiaryType,
      "firstNameOnAccount": firstNameController.text.toString(),
      "lastNameOnAccount": lastNameController.text.toString(),
      "beneficiaryAddress": addressController.text.toString(),
      "beneficiaryAddress2": addressController2.text.toString(),
      "beneficiaryCity": selectedCity,
      "beneficiaryPostal": postalController.text.toString(),
      "beneficiaryPhoneNumber": "+1${phoneNumberController.text.toString()}",
      "beneficaryState": selectedState.stateCode,
      "beneficiaryDobDay": selectedDate.day,
      "beneficiaryDobMonth": selectedDate.month,
      "beneficiaryDobYear": selectedDate.year,
      "accountNumber": accountController.text.toString(),
      "routingNumber": routingController.text.toString(),
      "accountType": accountType,
      "chargeablePM": false
    };

    try {
      var response = await http.post(HttpUrl.CREATE_PAYMENT_METHOD,
          body: jsonEncode(requestbody),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          loadingProgress = false;
        });
        jsonData = jsonDecode(response.body);
        if (jsonData['error'] == "false") {
          paymentMethodId = jsonData['data']['id'];
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => TransferToWallet(widget.coinSymbol,
                  userData, TransferType.bank, paymentMethodId),
            ),
          );
        } else {
          Utils().displayToast(jsonData['message'], context);
        }
      } else {
        setState(() {
          loadingProgress = false;
        });
        Utils().displayToast(jsonData['message'], context);
      }
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Color(AppTheme.gray2),
        ),
        centerTitle: true,
        title: Text(
          "Bank Transfer",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _bankFormKey,
          child: Column(
            children: [
              loadingProgress ? LinearProgressIndicator() : SizedBox(),
              Text(
                  "Wallet to bank transfer is only supported for US citizens."),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        mediaqueryWidth / 20.0,
                        0.0,
                        mediaqueryWidth / 20.0,
                        mediaqueryHeight / 90.0,
                      ),
                      child: CustomTextfield({
                        'inputFontSize': hwSize / 75.0,
                        'controller': firstNameController,
                        'hintText': "First Name",
                        'keyboardType': TextInputType.name,
                        'minLines': 1,
                        'obscureText': false,
                        'textCapitalization': TextCapitalization.words,
                        'textInputAction': TextInputAction.next,
                        'maxLength': 25,
                        'autofocus': false,
                        'enabled': true,
                        'counterText': '',
                        'onFieldSubmitted': (_) {},
                        'validator': (String value) {
                          if (value.isEmpty) {
                            return StringConstants.EMPTY_FIELD;
                          }
                          return null;
                        },
                      }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(mediaqueryWidth / 20.0, 0.0,
                          mediaqueryWidth / 20.0, mediaqueryHeight / 90.0),
                      child: CustomTextfield({
                        'inputFontSize': hwSize / 75.0,
                        'controller': lastNameController,
                        'hintText': "Last Name",
                        'keyboardType': TextInputType.name,
                        'minLines': 1,
                        'obscureText': false,
                        'textCapitalization': TextCapitalization.words,
                        'textInputAction': TextInputAction.next,
                        'maxLength': 25,
                        'autofocus': false,
                        'enabled': true,
                        'counterText': '',
                        'onFieldSubmitted': (_) {},
                        'validator': (value) {
                          if (value.isEmpty) {
                            return StringConstants.EMPTY_FIELD;
                          }
                          return null;
                        },
                      }),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: mediaqueryWidth / 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.only(bottom: 8.0),
                    //       child: Text("Benificiary Type"),
                    //     ),
                    //     Container(
                    //       padding: EdgeInsets.symmetric(horizontal: 5.0),
                    //       decoration: BoxDecoration(
                    //           color: Color(AppTheme.whiteGray),
                    //           border: Border.all(
                    //             width: 1.0,
                    //             color: Color(AppTheme.gray6),
                    //           ),
                    //           borderRadius: BorderRadius.circular(5.0)),
                    //       child: DropdownButtonHideUnderline(
                    //         child: DropdownButton(
                    //           value: beneficiaryType,
                    //           hint: Text("Beneficiary Type"),
                    //           onChanged: (changedVal) {
                    //             setState(() {
                    //               beneficiaryType = changedVal;
                    //             });
                    //           },
                    //           items: <String>["INDIVIDUAL", "CORPORATE"]
                    //               .map((String value) {
                    //             return DropdownMenuItem<String>(
                    //               value: value,
                    //               child: Text(value),
                    //             );
                    //           }).toList(),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Flexible(
                      child: CustomTextfield({
                        'inputFontSize': hwSize / 75.0,
                        'controller': routingController,
                        'hintText': "Routing Number",
                        'keyboardType': TextInputType.number,
                        'minLines': 1,
                        'obscureText': false,
                        'textCapitalization': TextCapitalization.none,
                        'textInputAction': TextInputAction.next,
                        'maxLength': 25,
                        'autofocus': false,
                        'enabled': true,
                        'counterText': '',
                        'onFieldSubmitted': (_) {},
                        'validator': (value) {
                          if (value.isEmpty) {
                            return StringConstants.EMPTY_FIELD;
                          }
                          return null;
                        },
                      }),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text("Account Type"),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                                color: Color(AppTheme.whiteGray),
                                border: Border.all(
                                  width: 1.0,
                                  color: Color(AppTheme.gray6),
                                ),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: accountType,
                                hint: Text("Account Type"),
                                onChanged: (changedVal) {
                                  setState(() {
                                    accountType = changedVal;
                                  });
                                },
                                items: <String>["CHECKING", "SAVINGS"]
                                    .map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  mediaqueryWidth / 20.0,
                  0.0,
                  mediaqueryWidth / 20.0,
                  mediaqueryHeight / 90.0,
                ),
                child: CustomTextfield({
                  'inputFontSize': hwSize / 75.0,
                  'controller': accountController,
                  'hintText': "Bank Account Number",
                  'keyboardType': TextInputType.number,
                  'minLines': 1,
                  'obscureText': false,
                  'textCapitalization': TextCapitalization.none,
                  'textInputAction': TextInputAction.next,
                  'maxLength': 25,
                  'autofocus': false,
                  'enabled': true,
                  'counterText': '',
                  'onFieldSubmitted': (_) {},
                  'validator': (value) {
                    if (value.isEmpty) {
                      return StringConstants.EMPTY_FIELD;
                    }
                    return null;
                  },
                }),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(mediaqueryWidth / 20.0, 0.0,
                    mediaqueryWidth / 20.0, mediaqueryHeight / 90.0),
                child: CustomTextfield({
                  'inputFontSize': hwSize / 75.0,
                  'controller': phoneNumberController,
                  'hintText': StringConstants.PHONE,
                  'keyboardType': TextInputType.phone,
                  'prefix': Text(
                    "+1 ",
                    style: TextStyle(color: Colors.black),
                  ),
                  'minLines': 1,
                  'obscureText': false,
                  'textCapitalization': TextCapitalization.none,
                  'textInputAction': TextInputAction.next,
                  'maxLength': 10,
                  'autofocus': false,
                  'enabled': true,
                  'counterText': '',
                  'onChanged': (val) {
                    setState(() {
                      isChanged = true;
                    });
                  },
                  'validator': (val) {
                    if (val.toString().isNotEmpty) {
                      if (val.length != 10) {
                        return "Invalid mobile number";
                      }
                    } else {
                      return StringConstants.EMPTY_FIELD;
                    }
                    return null;
                  }
                }),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(mediaqueryWidth / 20.0, 0.0,
                    mediaqueryWidth / 20.0, mediaqueryHeight / 90.0),
                child: CustomTextfield({
                  'inputFontSize': hwSize / 75.0,
                  'controller': addressController,
                  'hintText': "Address 1",
                  'keyboardType': TextInputType.streetAddress,
                  'minLines': 2,
                  'obscureText': false,
                  'textCapitalization': TextCapitalization.words,
                  'textInputAction': TextInputAction.next,
                  'maxLength': 200,
                  'autofocus': false,
                  'enabled': true,
                  'counterText': '',
                  'onFieldSubmitted': (_) {},
                  'validator': (value) {
                    if (value.isEmpty) {
                      return StringConstants.EMPTY_FIELD;
                    }
                    return null;
                  },
                }),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(mediaqueryWidth / 20.0, 0.0,
                    mediaqueryWidth / 20.0, mediaqueryHeight / 50.0),
                child: CustomTextfield({
                  'inputFontSize': hwSize / 75.0,
                  'controller': addressController2,
                  'hintText': "Address 2",
                  'keyboardType': TextInputType.streetAddress,
                  'minLines': 2,
                  'obscureText': false,
                  'textCapitalization': TextCapitalization.words,
                  'textInputAction': TextInputAction.done,
                  'maxLength': 200,
                  'autofocus': false,
                  'enabled': true,
                  'counterText': '',
                  'onFieldSubmitted': (_) {},
                  'validator': (value) {
                    if (value.isEmpty) {
                      return StringConstants.EMPTY_FIELD;
                    }
                    return null;
                  },
                }),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mediaqueryWidth / 20.0,
                ),
                child: Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Container(
                        width: 200.0,
                        height: 50.0,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(AppTheme.gray6),
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(5.0)),
                          color: Color(AppTheme.whiteGray),
                          onPressed: openDatePicker,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                selectedDate == null
                                    ? "D.O.B"
                                    : formatter.format(selectedDate),
                                style: TextStyle(
                                    color: Color(AppTheme.gray2),
                                    fontFamily: 'Poppins'),
                              ),
                              SizedBox(width: 18.0),
                              Icon(
                                Icons.date_range,
                                color: Color(AppTheme.gray2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: 30.0,
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: Color(AppTheme.whiteGray),
                            border: Border.all(
                              width: 1.0,
                              color: Color(AppTheme.gray6),
                            ),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<UsStates>(
                              hint: Text("State"),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                              },
                              validator: (val) {
                                if (val == null) {
                                  return "Select a State";
                                }
                                return null;
                              },
                              // underline: SizedBox(),
                              isExpanded: true,
                              value: selectedState,
                              items: usStateList.map((UsStates states) {
                                return DropdownMenuItem<UsStates>(
                                  value: states,
                                  child: Text(
                                    states.stateName,
                                    style: TextStyle(
                                      color: Color(AppTheme.gray2),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (UsStates states) {
                                setState(() {
                                  selectedState = states;
                                  isChanged = true;
                                  cityList = Assets()
                                      .statesAndCities[selectedState.stateName];
                                  selectedCity = cityList[0];
                                });
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaqueryWidth / 20.0, vertical: 20.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: Color(AppTheme.whiteGray),
                            border: Border.all(
                              width: 1.0,
                              color: Color(AppTheme.gray6),
                            ),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                              hint: Text("City"),
                              isExpanded: true,
                              validator: (val) {
                                if (val == null) {
                                  return "Select a City";
                                }
                                return null;
                              },
                              // underline: SizedBox(),
                              //     onTap: unfocusFields,
                              value: selectedCity,
                              items: cityList.map((city) {
                                return DropdownMenuItem(
                                  child: Text(
                                    city,
                                    style: TextStyle(
                                      color: Color(AppTheme.gray2),
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                  value: city,
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCity = newValue;
                                  isChanged = true;
                                });
                              }),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          mediaqueryWidth / 20.0,
                          0.0,
                          mediaqueryWidth / 20.0,
                          mediaqueryHeight / 90.0,
                        ),
                        child: CustomTextfield({
                          'inputFontSize': hwSize / 75.0,
                          'controller': postalController,
                          'hintText': "Postal Code",
                          'keyboardType': TextInputType.number,
                          'minLines': 1,
                          'obscureText': false,
                          'textCapitalization': TextCapitalization.none,
                          'textInputAction': TextInputAction.done,
                          'maxLength': 8,
                          'autofocus': false,
                          'enabled': true,
                          'counterText': '',
                          'onFieldSubmitted': (_) {},
                          'validator': (value) {
                            if (value.isEmpty) {
                              return StringConstants.EMPTY_FIELD;
                            }
                            return null;
                          },
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                onPressed: () {
                  if (_bankFormKey.currentState.validate()) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      loadingProgress = true;
                    });
                    createPayment();
                  }
                },
                child: Text(
                  "SUBMIT",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
