import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:kryptokafe/customwidgets/custom_textfield.dart';

class BankTransfer extends StatefulWidget {
  @override
  _BankTransferState createState() => _BankTransferState();
}

class _BankTransferState extends State<BankTransfer> {
  var accountType = false;
  TextEditingController firstNameController = TextEditingController(),
      lastNameController = TextEditingController(),
      addressController = TextEditingController(),
      addressAddress2 = TextEditingController(),
      cityController = TextEditingController(),
      postalController = TextEditingController(),
      phoneNumberController = TextEditingController(),
      stateController = TextEditingController(),
      accountController = TextEditingController(),
      routingController = TextEditingController();

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
      body: Form(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(mediaqueryWidth / 8.0, 0.0,
                  mediaqueryWidth / 8.0, mediaqueryHeight / 90.0),
              child: CustomTextfield({
                'inputFontSize': hwSize / 75.0,
                'controller': firstNameController,
                //  'hintText': StringConstants.EMAIL,
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
                  return null;
                },
              }),
            ),
          ],
        ),
      ),
    );
  }
}
