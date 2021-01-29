import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:kryptokafe/customwidgets/custom_textfield.dart';
import 'package:kryptokafe/customwidgets/primary_button.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Registeration extends StatefulWidget {
  @override
  _RegisterationState createState() => _RegisterationState();
}

class _RegisterationState extends State<Registeration> {
  bool autoValidation = false, internetStatus = false, loadingProgress = false;
  TextEditingController emailController = TextEditingController(),
      nameController = TextEditingController();
  FocusNode nameFocusNode = FocusNode(), emailFocusNode = FocusNode();
  var emailID,
      name,
      countryDialCode = "91",
      countryName = "India",
      countryCode = "IN",
      prefernces = KryptoSharedPreferences();
  Utils utils = Utils();

  // final sharedPreferences = SaphireSharedPreferences();
  final connectivity = Connectivity();
  final _loginformKey = GlobalKey<FormState>();

  showAlertDialog(BuildContext context, message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Verify"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  regApi(BuildContext buildContext) async {
    var jsonData;
    var requestBody = {
      "emailId": emailID,
      "name": name,
      "countryCallingCode": countryDialCode,
      "countryName": countryName,
      "countryCode": countryCode
    };
    var responseData = await http.post(HttpUrl.REGESTRATION, body: requestBody);
    try {
      if (responseData.statusCode == 200) {
        jsonData = jsonDecode(responseData.body);
        if (jsonData['error']) {
          setState(() {
            loadingProgress = false;
          });
          utils.displayToast(
            jsonData["message"],
            buildContext,
          );
        } else {
          showAlertDialog(context, jsonData["message"]);
          setState(() {
            loadingProgress = false;
          });

          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      } else if (responseData.statusCode == 500) {}
    } catch (e) {
      print(e);
    }
  }

  unFocusFields() {
    nameFocusNode.unfocus();
    emailFocusNode.unfocus();
  }

  @override
  void initState() {
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

  @override
  void dispose() {
    FocusNode().unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "Krypto Kafe",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 30.0,
              color: Colors.black,
              fontFamily: StringConstants.oxygenFontnameString,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Form(
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _loginformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                loadingProgress ? LinearProgressIndicator() : SizedBox(),
                SizedBox(
                  height: mediaqueryHeight / 10.0,
                ),
                Image.asset(
                  StringConstants.Krypto,
                  scale: 5.0,
                ),
                SizedBox(
                  height: mediaqueryHeight / 80.0,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(mediaqueryWidth / 8.0, 0.0,
                      mediaqueryWidth / 8.0, mediaqueryHeight / 90.0),
                  child: CustomTextfield({
                    'inputFontSize': hwSize / 75.0,
                    'controller': nameController,
                    'focusNode': nameFocusNode,
                    'hintText': "Name",
                    'keyboardType': TextInputType.text,
                    'minLines': 1,
                    'obscureText': false,
                    'textCapitalization': TextCapitalization.words,
                    'textInputAction': TextInputAction.next,
                    'maxLength': 50,
                    'autofocus': false,
                    'enabled': true,
                    'counterText': '',
                    'onFieldSubmitted': (_) {},
                    'validator': (value) {
                      if (value.toString().isNotEmpty) {
                        // handle login
                      } else {
                        return StringConstants.EMPTY_FIELD;
                      }

                      return null;
                    },
                  }),
                ),
                SizedBox(
                  height: mediaqueryHeight / 80.0,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(mediaqueryWidth / 8.0, 0.0,
                      mediaqueryWidth / 8.0, mediaqueryHeight / 90.0),
                  child: CustomTextfield({
                    'inputFontSize': hwSize / 75.0,
                    'controller': emailController,
                    'focusNode': emailFocusNode,
                    'hintText': StringConstants.EMAIL,
                    'keyboardType': TextInputType.emailAddress,
                    'minLines': 1,
                    'obscureText': false,
                    'textCapitalization': TextCapitalization.none,
                    'textInputAction': TextInputAction.next,
                    'maxLength': 50,
                    'autofocus': false,
                    'enabled': true,
                    'counterText': '',
                    'onFieldSubmitted': (_) {},
                    'validator': (value) {
                      if (value.toString().isNotEmpty) {
                        if (!utils.emailRegex.hasMatch(value)) {
                          return StringConstants.ERROR_EMAIL;
                        }
                      } else {
                        return StringConstants.EMPTY_FIELD;
                      }

                      return null;
                    },
                  }),
                ),
                CountryListPick(
                  appBar: AppBar(
                    backgroundColor: Colors.blue,
                    title: Text('Pick your Country'),
                  ),

                  // if you need custome picker use this
                  pickerBuilder: (context, CountryCode country) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaqueryWidth / 10.0),
                      padding: EdgeInsets.all(10.0),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Select your Country  - ",
                            style: TextStyle(
                              fontSize: hwSize / 70.0,
                            ),
                          ),
                          Text(
                            country.name + " ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: hwSize / 70.0,
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: hwSize / 70.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                  // To disable option set to false
                  theme: CountryTheme(
                    isShowFlag: true,
                    isShowTitle: true,
                    isShowCode: true,
                    isDownIcon: true,
                    showEnglishName: true,
                  ),
                  // Set default value
                  initialSelection: 'US',
                  onChanged: (CountryCode code) {
                    unFocusFields();
                    countryCode = code.code;
                    countryName = code.name;
                    if (code.dialCode == "+91")
                      countryDialCode = "91";
                    else
                      countryDialCode = code.dialCode;
                  },
                ),
                SizedBox(
                  height: mediaqueryHeight / 70.0,
                ),
                PrimaryButton({
                  "horizontalPadding": mediaqueryWidth / 7.0,
                  "verticalPadding": mediaqueryHeight / 75.0,
                  "fontSize": hwSize / 75.0,
                  "data": "SUBMIT"
                }, () {
                  if (_loginformKey.currentState.validate()) {
                    if (internetStatus) {
                      unFocusFields();
                      name = nameController.text.toString();
                      emailID = emailController.text.toString();
                      setState(() {
                        loadingProgress = true;
                      });
                      regApi(context);
                    } else {
                      utils.displayToast(
                          "Please check your Network Connection", context);
                    }
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
