///THIS FILE IS NOT USED IN THE APP

// import 'dart:convert';
// import 'package:connectivity/connectivity.dart';
// import 'package:kryptokafe/customwidgets/custom_textfield.dart';
// import 'package:kryptokafe/customwidgets/primary_button.dart';
// import 'package:kryptokafe/model/new_wallet.dart';
// import 'package:kryptokafe/model/state_codes.dart';
// import 'package:kryptokafe/utils/apptheme.dart';
// import 'package:kryptokafe/utils/assets.dart';
// import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
// import 'package:kryptokafe/utils/stringocnstants.dart';
// import 'package:kryptokafe/utils/utils.dart';
// import 'package:kryptokafe/wyre/wyre_api.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';

// class UserProfile extends StatefulWidget {
//   @override
//   _UserProfileState createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   final profileFormKey = GlobalKey<FormState>();
//   final DateFormat formatter = DateFormat('yyyy-MM-dd');
//   TextEditingController fullnameController = TextEditingController(),
//       mailController = TextEditingController(),
//       mobileController = TextEditingController(),
//       ssnController = TextEditingController(),
//       street1Controller = TextEditingController(),
//       street2Controller = TextEditingController(),
//       cityController = TextEditingController(),
//       postalController = TextEditingController(),
//       stateCodeController = TextEditingController();

//   var userName = "",
//       userEmail = "",
//       userPhonenumber = "",
//       accoutnId = "",
//       ssn = "",
//       street1 = "",
//       street2 = "",
//       city = "",
//       stateCode = "",
//       postalCode = "",
//       countryCode = "US",
//       accountStatus = "",
//       dateOfBirth = "";

//   NewWallet _wallet;
//   Utils utils = Utils();
//   var prefernces = KryptoSharedPreferences(), walletId, selectedStateIndex;
//   UsStates selectedState;
//   bool loadingProgress = false,
//       showShimmer = false,
//       isChanged = true,
//       showDobError = false,
//       internetStatus = false;
//   List<String> cityList = [];
//   List<UsStates> usStateList = [];
//   String selectedCity;
//   DateTime selectedDate;
//   Connectivity connectivity = Connectivity();

//   @override
//   void initState() {
//     super.initState();
//     connectivity.checkConnectivity().then(onInternetStatus);
//     connectivity.onConnectivityChanged.listen(onInternetStatus);
//     getUserData();
//   }

//   onInternetStatus(value) {
//     if (value == ConnectivityResult.mobile ||
//         value == ConnectivityResult.wifi) {
//       setState(() {
//         internetStatus = true;
//       });
//     } else {
//       setState(() {
//         internetStatus = false;
//       });
//     }
//   }

//   getUserData() async {
//     usStateList = UsStates().getStateList();

//     try {
//       _wallet = NewWallet.fromJson(await prefernces.read("wallet"));

//       walletId = _wallet.id;

//       initialize();
//     } catch (e) {
//       print("exception  $e");
//     }
//   }

//   initialize() {
//     //coutryController.text = countryCode;

//     var list = usStateList;
//     selectedState = list[0];

//     if (selectedState != null)
//       cityList = Assets().statesAndCities[selectedState.stateName];
//     selectedCity = cityList[0];

//     setState(() {
//       showShimmer = false;
//     });
//   }

//   updateUserApi() async {
//     var url, requestBody = {}, verificationData = {};

//     Map addressValue = {
//       "street1": street1Controller.text.toString(),
//       "street2": street2Controller.text.toString(),
//       "city": selectedCity,
//       "state": selectedState.stateCode,
//       "postalCode": postalController.text.toString(),
//       "country": countryCode
//     };

//     verificationData = {
//       "firstName": "Danny",
//       "middleName": "",
//       "lastName": "test",
//       "ssn": ssnController.text.toString(),
//       "passport": "123456",
//       "birthDay": selectedDate.day.toString(),
//       "birthMonth": selectedDate.month.toString(),
//       "birthYear": selectedDate.year.toString(),
//       "phoneNumber": "+1${mobileController.text.toString()}",
//       "address": addressValue
//     };

//     requestBody = {"verificationData": verificationData};

//     try {
//       url = WyreApi.WYRE_BASE +
//           "v2" +
//           "/wallet" +
//           "/$walletId/update" +
//           "?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
//       var jsonBody = jsonEncode(requestBody);
//       // url =
//       //     "https://api.testwyre.com/v2/wallet/WA_NEBCL7FFT3W/update?timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
//       var response = await http.post(url,
//           headers: {
//             "Content-Type": "application/json",
//             "X-Api-Key": WyreApi.AAPI__KEY,
//             "X-Api-Signature": utils.signature(url: url, data: jsonBody)
//           },
//           body: jsonBody);

//       if (response.statusCode == 200) {
//         //todo: change the model class of NewWallet to add verificatio data
//         NewWallet wallet = NewWallet.fromJson(jsonDecode(response.body));
//         prefernces.save("wallet", wallet);

//         // getUserData();
//         setState(() {
//           loadingProgress = false;
//         });
//       } else {
//         setState(() {
//           loadingProgress = false;
//         });
//         var msg = jsonDecode(response.body);
//         //   utils.displayToast(msg['message'], context);
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text("Error"),
//                 content: Text(msg['message']),
//                 actions: [
//                   FlatButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text("Close"))
//                 ],
//               );
//             });
//       }
//       print(response.body);
//     } catch (e) {}
//   }

//   openDatePicker() async {
//     FocusScope.of(context).unfocus();

//     final DateTime picked = await showDatePicker(
//         initialDatePickerMode: DatePickerMode.day,
//         initialEntryMode: DatePickerEntryMode.calendar,
//         context: context,
//         firstDate: DateTime(DateTime.now().year - 100, 1),
//         initialDate: selectedDate == null
//             ? DateTime(DateTime.now().year - 18, 1, 1)
//             : selectedDate,
//         lastDate: DateTime(DateTime.now().year - 18, 12, 31),
//         builder: (BuildContext context, Widget child) {
//           return Theme(
//               data: ThemeData(primarySwatch: Colors.red), child: child);
//         });

//     if (picked != null && picked != selectedDate)
//       setState(() {
//         isChanged = true;
//         selectedDate = picked;
//         showDobError = false;
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var mediaqueryHeight = MediaQuery.of(context).size.height;
//     var mediaqueryWidth = MediaQuery.of(context).size.width;
//     var hwSize = mediaqueryHeight + mediaqueryWidth;
//     var sizedBox = SizedBox(
//       height: mediaqueryHeight / 60,
//     );
//     var spaceBox = SizedBox(
//       height: mediaqueryHeight / 40,
//     );

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           elevation: 0.0,
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios),
//             color: Color(AppTheme.gray2),
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//           ),
//         ),
//         body: showShimmer
//             ? Container(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[100],
//                   highlightColor: Colors.grey[200],
//                   enabled: true,
//                   child: Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: <Widget>[
//                             Expanded(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey,
//                                 ),
//                                 height: mediaqueryHeight / 15.0,
//                                 width: mediaqueryWidth / 4.0,
//                               ),
//                             )
//                           ],
//                         ),
//                         spaceBox,
//                         Container(
//                           color: Colors.grey,
//                           height: 10.0,
//                           width: mediaqueryWidth / 2.0,
//                         ),
//                         spaceBox,
//                         Container(
//                           color: Colors.grey,
//                           height: 10.0,
//                           width: mediaqueryWidth / 5.0,
//                         ),
//                         spaceBox,
//                         Container(
//                           color: Colors.grey,
//                           height: 10.0,
//                           width: mediaqueryWidth / 3.0,
//                         ),
//                         spaceBox,
//                         Container(
//                           color: Colors.grey,
//                           height: 10.0,
//                           width: mediaqueryWidth / 2.0,
//                         ),
//                         spaceBox,
//                         Container(
//                           color: Colors.grey,
//                           height: 10.0,
//                           width: mediaqueryWidth / 1.5,
//                         ),
//                         spaceBox,
//                         spaceBox,
//                         Center(
//                           child: Container(
//                             height: 50.0,
//                             width: mediaqueryWidth / 3.0,
//                             color: Colors.grey,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
//                   child: Form(
//                     onChanged: () {
//                       if (selectedDate == null) {
//                         setState(() {
//                           showDobError = true;
//                         });
//                       }
//                     },
//                     key: profileFormKey,
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     child: Column(
//                       children: <Widget>[
//                         loadingProgress
//                             ? LinearProgressIndicator()
//                             : SizedBox(),
//                         Align(
//                           alignment: Alignment.topLeft,
//                           child: Text(
//                             "Profile",
//                             style: TextStyle(
//                                 fontSize: hwSize / 45.0,
//                                 color: Color(AppTheme.gray2),
//                                 //   fontFamily: AppTheme.poppins,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                         sizedBox,
//                         CustomTextfield({
//                           'inputFontSize': hwSize / 75.0,
//                           'controller': fullnameController,
//                           'hintText': StringConstants.FULLNAME,
//                           'keyboardType': TextInputType.text,
//                           'minLines': 1,
//                           'obscureText': false,
//                           'textCapitalization': TextCapitalization.words,
//                           'textInputAction': TextInputAction.next,
//                           'maxLength': 20,
//                           'autofocus': false,
//                           'enabled': false,
//                           'counterText': '',
//                           'onChanged': (_) {
//                             setState(() {
//                               isChanged = true;
//                             });
//                           },
//                           // 'validator': (val) {
//                           //   if (val.toString().isNotEmpty) {
//                           //     if (!utils.fullnameRegex.hasMatch(val)) {
//                           //       return 'Invalid input';
//                           //     }
//                           //   } else {
//                           //     return StringConstants.EMPTY_FIELD;
//                           //   }

//                           //   return null;
//                           // }
//                         }),
//                         sizedBox,
//                         Row(
//                           children: [
//                             Flexible(
//                               flex: 10,
//                               child: CustomTextfield({
//                                 'inputFontSize': hwSize / 75.0,
//                                 'controller': mailController,
//                                 'hintText': StringConstants.EMAIL,
//                                 'keyboardType': TextInputType.emailAddress,
//                                 'minLines': 1,
//                                 'obscureText': false,
//                                 'textCapitalization': TextCapitalization.none,
//                                 'textInputAction': TextInputAction.next,
//                                 'maxLength': 50,
//                                 'autofocus': false,
//                                 'enabled': true,
//                                 'counterText': '',
//                                 'onChanged': (_) {
//                                   setState(() {
//                                     isChanged = true;
//                                   });
//                                 },
//                                 // 'validator': (val) {
//                                 //   if (val.toString().isNotEmpty) {
//                                 //     if (!utils.emailRegex.hasMatch(val)) {
//                                 //       return StringConstants.ERROR_EMAIL;
//                                 //     }
//                                 //   } else {
//                                 //     return StringConstants.EMPTY_FIELD;
//                                 //   }
//                                 //   return null;
//                                 // }
//                               }),
//                             ),
//                             SizedBox(
//                               width: mediaqueryWidth / 20.0,
//                             ),
//                             Flexible(
//                               flex: 7,
//                               child: Column(
//                                 children: [
//                                   ButtonTheme(
//                                     minWidth: 100.0,
//                                     child: FlatButton(
//                                       shape: RoundedRectangleBorder(
//                                           side: BorderSide(
//                                               color: Color(AppTheme.gray6),
//                                               width: 1,
//                                               style: BorderStyle.solid),
//                                           borderRadius:
//                                               BorderRadius.circular(5.0)),
//                                       color: Color(AppTheme.whiteGray),
//                                       onPressed: openDatePicker,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: <Widget>[
//                                           Text(
//                                             selectedDate == null
//                                                 ? "D.O.B"
//                                                 : formatter
//                                                     .format(selectedDate),
//                                             style: TextStyle(
//                                                 color: Color(AppTheme.gray2),
//                                                 fontFamily: 'Poppins'),
//                                           ),
//                                           SizedBox(width: 18.0),
//                                           Icon(
//                                             Icons.date_range,
//                                             color: Color(AppTheme.gray2),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Visibility(
//                                     visible: showDobError,
//                                     child: Align(
//                                       alignment: Alignment.topLeft,
//                                       child: Text(
//                                         "Invalid Date",
//                                         style: TextStyle(
//                                             fontSize: 12.0, color: Colors.blue),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                         sizedBox,
//                         Row(
//                           children: [
//                             Flexible(
//                               child: CustomTextfield({
//                                 'inputFontSize': hwSize / 75.0,
//                                 'controller': mobileController,
//                                 'hintText': StringConstants.PHONE,
//                                 'keyboardType': TextInputType.phone,
//                                 'prefix': Text(
//                                   "+1 ",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                                 'minLines': 1,
//                                 'obscureText': false,
//                                 'textCapitalization': TextCapitalization.none,
//                                 'textInputAction': TextInputAction.done,
//                                 'maxLength': 10,
//                                 'autofocus': false,
//                                 'enabled': true,
//                                 'counterText': '',
//                                 'onChanged': (val) {
//                                   setState(() {
//                                     isChanged = true;
//                                   });
//                                 },
//                                 'validator': (val) {
//                                   if (val.toString().isNotEmpty) {
//                                     if (val.length != 10) {
//                                       return "Invalid mobile number";
//                                     }
//                                   } else {
//                                     return StringConstants.EMPTY_FIELD;
//                                   }
//                                   return null;
//                                 }
//                               }),
//                             ),
//                             SizedBox(
//                               width: mediaqueryWidth / 20.0,
//                             ),
//                             Flexible(
//                               child: CustomTextfield({
//                                 'inputFontSize': hwSize / 75.0,
//                                 'controller': ssnController,
//                                 'hintText': StringConstants.SSN,
//                                 'keyboardType': TextInputType.text,
//                                 // 'inputFormatters': [
//                                 //   FilteringTextInputFormatter.digitsOnly,
//                                 //   // FilteringTextInputFormatter.allow(RegExp(r'[+]')),
//                                 // ],
//                                 'minLines': 1,
//                                 'obscureText': false,
//                                 'textCapitalization': TextCapitalization.none,
//                                 'textInputAction': TextInputAction.done,
//                                 'maxLength': 9,
//                                 'autofocus': false,
//                                 'enabled': true,
//                                 'counterText': '',
//                                 'onChanged': (val) {
//                                   setState(() {
//                                     isChanged = true;
//                                   });
//                                 },
//                                 'validator': (val) {
//                                   if (val.toString().isNotEmpty) {
//                                     // if (val.length != 9) {
//                                     //   return "Invalid number";
//                                     // }
//                                   } else {
//                                     return StringConstants.EMPTY_FIELD;
//                                   }
//                                   return null;
//                                 }
//                               }),
//                             ),
//                           ],
//                         ),
//                         sizedBox,
//                         Row(
//                           children: [
//                             Flexible(
//                               child: CustomTextfield({
//                                 'inputFontSize': hwSize / 75.0,
//                                 'controller': street1Controller,
//                                 // 'focusNode': addressFocusNode,
//                                 'hintText': 'Street1',
//                                 'keyboardType': TextInputType.streetAddress,
//                                 'minLines': 1,
//                                 'maxLines': 1,
//                                 'obscureText': false,
//                                 'textCapitalization': TextCapitalization.words,
//                                 'textInputAction': TextInputAction.done,
//                                 'maxLength': 20,
//                                 'autofocus': false,
//                                 'counterText': '',
//                                 'onChanged': (_) {
//                                   setState(() {
//                                     isChanged = true;
//                                   });
//                                 },

//                                 'validator': (val) {
//                                   if (val.toString().isNotEmpty) {
//                                     if (val.toString().length < 2) {
//                                       return StringConstants.INVALID_INPUT;
//                                     }
//                                   } else {
//                                     return StringConstants.EMPTY_FIELD;
//                                   }

//                                   return null;
//                                 }
//                               }),
//                             ),
//                             SizedBox(
//                               width: mediaqueryWidth / 20.0,
//                             ),
//                             Flexible(
//                               child: CustomTextfield({
//                                 'inputFontSize': hwSize / 75.0,
//                                 'controller': street2Controller,
//                                 // 'focusNode': addressFocusNode,
//                                 'hintText': 'Street2',
//                                 'keyboardType': TextInputType.streetAddress,
//                                 'minLines': 1,
//                                 'maxLines': 1,
//                                 'obscureText': false,
//                                 'textCapitalization': TextCapitalization.words,
//                                 'textInputAction': TextInputAction.done,
//                                 'maxLength': 20,
//                                 'autofocus': false,
//                                 'counterText': '',
//                                 'onChanged': (_) {
//                                   setState(() {
//                                     isChanged = true;
//                                   });
//                                 },
//                                 'onFieldSubmitted': (_) {
//                                   // utils.fieldFocusChange(
//                                   //     context, addressFocusNode, FocusNode());
//                                 },
//                                 'validator': (val) {
//                                   if (val.toString().isNotEmpty) {
//                                     if (val.toString().length < 2) {
//                                       return StringConstants.INVALID_INPUT;
//                                     }
//                                   } else {
//                                     return StringConstants.EMPTY_FIELD;
//                                   }

//                                   return null;
//                                 }
//                               }),
//                             ),
//                           ],
//                         ),
//                         sizedBox,
//                         CustomTextfield({
//                           'inputFontSize': hwSize / 75.0,
//                           'controller': postalController,
//                           // 'focusNode': addressFocusNode,
//                           'hintText': 'Postal Code',
//                           'keyboardType': TextInputType.text,
//                           'minLines': 1,
//                           'maxLines': 1,
//                           'obscureText': false,
//                           'textCapitalization': TextCapitalization.words,
//                           'textInputAction': TextInputAction.done,
//                           'maxLength': 20,
//                           'autofocus': false,
//                           'counterText': '',
//                           'onChanged': (_) {
//                             setState(() {
//                               isChanged = true;
//                             });
//                           },
//                           'onFieldSubmitted': (_) {
//                             // utils.fieldFocusChange(
//                             //     context, addressFocusNode, FocusNode());
//                           },
//                           'validator': (val) {
//                             if (val.toString().isNotEmpty) {
//                               if (val.toString().length < 2) {
//                                 return StringConstants.INVALID_INPUT;
//                               }
//                             } else {
//                               return StringConstants.EMPTY_FIELD;
//                             }

//                             return null;
//                           }
//                         }),
//                         SizedBox(
//                           height: mediaqueryHeight / 30,
//                         ),
//                         Row(
//                           children: [
//                             Flexible(
//                               flex: 4,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 5.0),
//                                 decoration: BoxDecoration(
//                                     color: Color(AppTheme.whiteGray),
//                                     border: Border.all(
//                                       width: 1.0,
//                                       color: Color(AppTheme.gray6),
//                                     ),
//                                     borderRadius: BorderRadius.circular(5.0)),
//                                 child: DropdownButtonHideUnderline(
//                                   child: DropdownButtonFormField<UsStates>(
//                                       hint: Text("State"),
//                                       onTap: () {
//                                         FocusScope.of(context).unfocus();
//                                       },
//                                       validator: (val) {
//                                         if (val == null) {
//                                           return "Select a State";
//                                         }
//                                         return null;
//                                       },
//                                       // underline: SizedBox(),
//                                       isExpanded: true,
//                                       value: selectedState,
//                                       items: usStateList.map((UsStates states) {
//                                         return DropdownMenuItem<UsStates>(
//                                           value: states,
//                                           child: Text(
//                                             states.stateName,
//                                             style: TextStyle(
//                                               color: Color(AppTheme.gray2),
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       onChanged: (UsStates states) {
//                                         setState(() {
//                                           selectedState = states;
//                                           isChanged = true;
//                                           cityList = Assets().statesAndCities[
//                                               selectedState.stateName];
//                                           selectedCity = cityList[0];
//                                         });
//                                       }),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: mediaqueryWidth / 20.0,
//                             ),
//                             Flexible(
//                               flex: 6,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 5.0),
//                                 decoration: BoxDecoration(
//                                     color: Color(AppTheme.whiteGray),
//                                     border: Border.all(
//                                       width: 1.0,
//                                       color: Color(AppTheme.gray6),
//                                     ),
//                                     borderRadius: BorderRadius.circular(5.0)),
//                                 child: DropdownButtonHideUnderline(
//                                   child: DropdownButtonFormField(
//                                       hint: Text("City"),
//                                       isExpanded: true,
//                                       validator: (val) {
//                                         if (val == null) {
//                                           return "Select a City";
//                                         }
//                                         return null;
//                                       },
//                                       // underline: SizedBox(),
//                                       //     onTap: unfocusFields,
//                                       value: selectedCity,
//                                       items: cityList.map((city) {
//                                         return DropdownMenuItem(
//                                           child: Text(
//                                             city,
//                                             style: TextStyle(
//                                               color: Color(AppTheme.gray2),
//                                             ),
//                                             overflow: TextOverflow.fade,
//                                           ),
//                                           value: city,
//                                         );
//                                       }).toList(),
//                                       onChanged: (newValue) {
//                                         setState(() {
//                                           selectedCity = newValue;
//                                           isChanged = true;
//                                         });
//                                       }),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         sizedBox,
//                         SizedBox(
//                           height: mediaqueryHeight / 9.0,
//                         ),
//                         PrimaryButton(
//                             {
//                               "horizontalPadding": mediaqueryWidth / 7.0,
//                               "verticalPadding": mediaqueryHeight / 75.0,
//                               "fontSize": hwSize / 75.0,
//                               "data": "SUBMIT"
//                             },
//                             isChanged
//                                 ? () {
//                                     FocusScope.of(context).unfocus();
//                                     if (profileFormKey.currentState
//                                         .validate()) {
//                                       if (selectedDate == null) {
//                                         setState(() {
//                                           showDobError = true;
//                                         });
//                                       } else if (internetStatus) {
//                                         setState(() {
//                                           loadingProgress = true;
//                                         });
//                                         updateUserApi();
//                                       } else {
//                                         utils.displayToast(
//                                             "Please check your internet connection",
//                                             context);
//                                       }
//                                     }
//                                   }
//                                 : null)
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
