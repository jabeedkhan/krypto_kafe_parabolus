//import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:kryptokafe/customwidgets/primary_button.dart';
import 'package:kryptokafe/model/userdetails.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:path/path.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadDocuments extends StatefulWidget {
  @override
  _UploadDocumentsState createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  var frontPath, backPath, preferences = KryptoSharedPreferences();
  Utils utils = Utils();
  File frontFile, backFile;
  Map documentType;
  String documentSelected, docType, frontSide, backSide, accountId;
  UserDetails user;

  pickFile(side) async {
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ["jpeg", "png", "pdf"],
        allowedMimeTypes: ['application/pdf', 'image/png', 'image/jpeg'],
      );

      if (side == "0") {
        frontPath = await FlutterDocumentPicker.openDocument(params: params);
        setState(() {
          frontFile = File(frontPath);
          frontSide = basename(frontFile.path);
        });
        print(frontSide);
      } else if (side == "1") {
        backPath = await FlutterDocumentPicker.openDocument(params: params);
        setState(() {
          backFile = File(backPath);
          backSide = basename(backFile.path);
        });
        print(backSide);
      }
    } catch (excep) {}
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    documentType = {
      "Goverment Id": "GOVT_ID",
      "Driving License": "DRIVING_LICENSE",
      "Passport Card": "PASSPORT_CARD",
      "Passport": "PASSPORT"
    };
    documentSelected = "Goverment Id";
    docType = "GOVT_ID";
    frontSide = "No file selected (Front)";
    backSide = "No file selected (Back)";
  }

  sendFile() async {
    var url, data;
    Map<String, String> headers;
    try {
      user = UserDetails.fromJson(await preferences.read("user"));
      accountId = user.id;
      // url = WyreApi.WYRE_BASE +
      //     WyreApi.ACCOUNT +
      //     "/$accountId?masqueradeAs=$accountId" +
      //     "/${WyreKey.fieldResGovermrntId}"
      //         "?documentType=$docType"
      //         "&documentSubType=FRONT"
      //         "&timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";

      url =
          "https://api.testwyre.com/v3/accounts/$accountId?masqueradeAs=$accountId/individualProofOfAddress?documentType=DRIVING_LICENSE&documentSubType=FRONT&timestamp=${DateTime.now().toUtc().millisecondsSinceEpoch}";
      var uri = Uri.parse(url);
      data = http.MultipartFile.fromBytes(
          'individualGovernmentId', frontFile.readAsBytesSync(),
          filename: frontPath.split("/").last,
          contentType: MediaType('application', 'pdf'));
      // print(data);

      // headers = {
      //   "Content-Type": "application/pdf",
      //   "X-Api-Key": WyreApi.AAPI__KEY,
      //   "X-Api-Signature": utils.signatureBuffer(url: url, data: data)
      // };

      headers = {
        "Content-Type": "multipart/form-data",
        "Authorization": "Bearer SK-7JDBQJWE-NLY489JD-7VBQWVZX-HMCGR8DR",
        // "X-Api-Signature": utils.signature(
        //   url: url,
        // )
      };

      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(data);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        print(response.body);
      }
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  showInfoDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Uploading Documents"),
          content: Text(
              "Please Upload any one of your valid ID both front and back side. Only PNG, JPEG and PDF formats are allowed and the Maximum file upload size is 7.75MB"),
          actions: [],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline_rounded, color: Colors.black),
              onPressed: () {
                showInfoDialog(context);
              })
        ],
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: mediaqueryHeight / 30.0,
          ),
          Center(
              child: Text(
            "Upload any one these documents to get your profile verified",
            style: TextStyle(fontSize: mediaqueryHeight / 50.0),
          )),
          DropdownButton<String>(
            items: documentType
                .map((description, value) {
                  return MapEntry(
                      description,
                      DropdownMenuItem<String>(
                          value: description,
                          child: Text(description,
                              style: TextStyle(
                                  fontSize: mediaqueryHeight / 50.0))));
                })
                .values
                .toList(),
            value: documentSelected,
            onChanged: (String val) {
              setState(() {
                documentSelected = val;
              });
            },
            style: new TextStyle(
              color: Colors.black,
            ),
          ),
          GestureDetector(
              child: Container(
                margin: EdgeInsets.all(hwSize / 90.0),
                decoration: BoxDecoration(
                    color: Color(AppTheme.gray6),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(2, 2),
                          blurRadius: 4.0)
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                width: mediaqueryWidth,
                child: Text(frontSide),
              ),
              onTap: () {
                pickFile("0");
              }),
          GestureDetector(
              child: Container(
                margin: EdgeInsets.all(hwSize / 90.0),
                decoration: BoxDecoration(
                    color: Color(AppTheme.gray6),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(2, 2),
                          blurRadius: 4.0)
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                width: mediaqueryWidth,
                child: Text(backSide),
              ),
              onTap: () {
                pickFile("1");
              }),
          SizedBox(
            height: 30.0,
          ),
          PrimaryButton({
            "horizontalPadding": mediaqueryWidth / 7.0,
            "verticalPadding": mediaqueryHeight / 75.0,
            "fontSize": hwSize / 75.0,
            "data": "SUBMIT"
          }, () {
            sendFile();
          })
        ],
      ),
    );
  }
}
