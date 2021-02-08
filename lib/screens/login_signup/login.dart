import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/customwidgets/custom_password_field.dart';
import 'package:kryptokafe/customwidgets/custom_textfield.dart';
import 'package:kryptokafe/customwidgets/primary_button.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/screens/login_signup/registration.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool autoValidation = false, internetStatus = false, loadingProgress = false;
  TextEditingController emailController = TextEditingController(),
      forgotPasswordEmailController = TextEditingController(),
      passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode(),
      passwordFocusNode = FocusNode(),
      forgotPasswordFocusNode = FocusNode();
  var emailID,
      forgotPasswordemailID,
      password,
      prefernces = KryptoSharedPreferences();
  Utils utils = Utils();
  UserData userData;

  // final sharedPreferences = SaphireSharedPreferences();
  final connectivity = Connectivity();
  final _loginformKey = GlobalKey<FormState>();

  loginApi(BuildContext buildContext) async {
    var jsonData;
    var requestBody = {"emailId": emailID, "password": password};
    try {
      var responseData = await http.post(HttpUrl.LOGIN, body: requestBody);
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
          userData = UserData.fromJson(jsonData);
          prefernces.save(StringConstants.USER_DATA, userData);
          prefernces.setString(StringConstants.LOGIN_STATUS, '1');

          if (userData.data.walletId != null)
            lookUpWallet();
          else
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Home(0)));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  lookUpWallet() async {
    try {
      var request = await http
          .post(HttpUrl.LOOKUP_WALLET, body: {"user_id": userData.data.id.toString() });

      if (request.statusCode == 200) {
        var jsonBody = jsonDecode(request.body);

        if (!jsonBody['error']) {
          NewWallet wallet = NewWallet.fromJson(jsonBody['data']);
          prefernces.save("wallet", wallet);
        }
        setState(() {
          loadingProgress = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home(0)));
      } else {
        utils.displayToast(request.reasonPhrase, context);
        setState(() {
          loadingProgress = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void unFocusFields() {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
  }

  @override
  void dispose() {
    FocusNode().unfocus();
    super.dispose();
  }

  @override
  void initState() {
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    super.initState();
  }

  showAlertDialog(BuildContext context, message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Reset Your Password"),
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

  forgotPassword() async {
    var jsonData;
    var requestBody = {"emailId": forgotPasswordemailID};
    var responseData =
        await http.post(HttpUrl.FORGOT_PASSWORD, body: requestBody);
    if (responseData.statusCode == 200) {
      jsonData = jsonDecode(responseData.body);
      if (jsonData['error']) {
        showAlertDialog(context, jsonData["message"]);
        setState(() {
          loadingProgress = false;
        });
      } else {
        showAlertDialog(context, jsonData["message"]);
        setState(() {
          loadingProgress = false;
        });
      }
    }
  }

  //forgot password dialog
  Future buildShowDialog(BuildContext context, double mediaqueryHeight,
      double mediaqueryWidth, double hwSize) {
    final emailFormKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: emailFormKey,
                child: Container(
                  height: mediaqueryHeight / 2.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Enter your registered mail Id",
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: CustomTextfield({
                            'inputFontSize': hwSize / 75.0,
                            'controller': forgotPasswordEmailController,
                            'focusNode': forgotPasswordFocusNode,
                            'hintText': StringConstants.EMAIL,
                            'keyboardType': TextInputType.emailAddress,
                            'minLines': 1,
                            'obscureText': false,
                            'textCapitalization': TextCapitalization.none,
                            'maxLength': 50,
                            'autofocus': false,
                            'enabled': true,
                            'counterText': '',
                            'validator': (val) {
                              if (val.toString().isNotEmpty) {
                                if (!utils.emailRegex.hasMatch(val)) {
                                  return StringConstants.ERROR_EMAIL;
                                }
                              } else {
                                return StringConstants.EMPTY_FIELD;
                              }
                              return null;
                            }
                          }),
                        ),
                        PrimaryButton({
                          "horizontalPadding": mediaqueryWidth / 7.0,
                          "verticalPadding": mediaqueryHeight / 75.0,
                          "fontSize": hwSize / 75.0,
                          "data": "SUBMIT"
                        }, () {
                          if (emailFormKey.currentState.validate()) {
                            forgotPasswordFocusNode.unfocus();
                            if (internetStatus) {
                              forgotPasswordemailID =
                                  forgotPasswordEmailController.text.toString();
                              setState(() {
                                loadingProgress = true;
                              });
                              forgotPassword();
                              Navigator.pop(context);
                            }
                          }
                        })
                      ],
                    ),
                  ),
                ),
              ));
        });
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
                Padding(
                  padding: EdgeInsets.fromLTRB(mediaqueryWidth / 8.0, 0.0,
                      mediaqueryWidth / 8.0, mediaqueryHeight / 90.0),
                  child: CustomPasswordField({
                    'inputFontSize': hwSize / 75.0,
                    'controller': passwordController,
                    'focusNode': passwordFocusNode,
                    'hintText': StringConstants.PASSWORD,
                    'keyboardType': TextInputType.visiblePassword,
                    'minLines': 1,
                    'obscureText': true,
                    'textCapitalization': TextCapitalization.none,
                    'textInputAction': TextInputAction.done,
                    'maxLength': 15,
                    'autofocus': false,
                    'counterText': '',
                    'validator': (val) {
                      if (val.toString().isNotEmpty) {
                        if (val.toString().length < 5) {
                          return StringConstants.ERROR_PASSWRD;
                        }
                      } else {
                        return StringConstants.EMPTY_FIELD;
                      }

                      return null;
                    }
                  }),
                ),
                SizedBox(
                  height: mediaqueryHeight / 70.0,
                ),
                Padding(
                  padding: EdgeInsets.only(right: mediaqueryWidth / 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: () {
                        buildShowDialog(
                            context, mediaqueryHeight, mediaqueryWidth, hwSize);
                      },
                      child: Text(
                        StringConstants.FORGOT_PASSWORD,
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: hwSize / 75.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: mediaqueryHeight / 40.0,
                ),
                PrimaryButton({
                  "horizontalPadding": mediaqueryWidth / 7.0,
                  "verticalPadding": mediaqueryHeight / 75.0,
                  "fontSize": hwSize / 75.0,
                  "data": "SUBMIT"
                }, () {
                  if (_loginformKey.currentState.validate()) {
                    unFocusFields();
                    if (internetStatus) {
                      emailID = emailController.text.toString();
                      password = passwordController.text.toString();
                      setState(() {
                        loadingProgress = true;
                      });
                      loginApi(context);
                    } else {
                      utils.displayToast(
                          "Please check your Network Connection", context);
                    }
                  }
                }),
                SizedBox(
                  height: mediaqueryHeight / 70.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Registeration()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: mediaqueryHeight / 50.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800]),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
