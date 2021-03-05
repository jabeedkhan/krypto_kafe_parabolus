import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/utils/http_url.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/utils.dart';
import 'package:kryptokafe/utils/apptheme.dart';
import 'package:kryptokafe/screens/profile/transfer_details.dart';

class TransferHistory extends StatefulWidget {
  @override
  _TransferHistoryState createState() => _TransferHistoryState();
}

class _TransferHistoryState extends State<TransferHistory> {
  bool isLoading = true, isDataAvailable = true;
  KryptoSharedPreferences preferences = KryptoSharedPreferences();
  UserData _userData;
  Utils utils;
  List transferData;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    _userData =
        UserData.fromJson(await preferences.read(StringConstants.USER_DATA));
    getAlltransfer();
  }

  getAlltransfer() async {
    var request = {"user_id": _userData.data.id}, jsonData;
    try {
      var response = await http.post(HttpUrl.GET_ALL_TRANSFER,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(request));

      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        if (jsonData['error'] == false) {
          transferData = jsonData['data'];
          setState(() {
            isLoading = false;
            isDataAvailable = true;
          });
        } else {
          setState(() {
            isLoading = false;
            isDataAvailable = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  TextStyle headerStyle() {
    return TextStyle(
        color: Color(AppTheme.gray3),
        fontSize: 16.0,
        fontWeight: FontWeight.w600);
  }

  TextStyle subStyle() {
    return TextStyle(
        color: Color(AppTheme.gray2),
        fontSize: 16.0,
        fontWeight: FontWeight.w600);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Transfer History",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : isDataAvailable
                ? ListView.builder(
                    itemCount: transferData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Card(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(color: Colors.white),
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Transaction Type : ",
                                      style: headerStyle(),
                                    ),
                                    Text(
                                      transferData[index]["type"] ?? "N/A",
                                      style: subStyle(),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Transaction ID :",
                                      style: headerStyle(),
                                    ),
                                    Expanded(
                                        child: Text(
                                      transferData[index]["transfer_id"] ?? "",
                                      style: subStyle(),
                                    )),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Payment ID :",
                                      style: headerStyle(),
                                    ),
                                    Text(
                                      transferData[index]["payment_id"] ??
                                          "N/A",
                                      style: subStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Payment Request Status :",
                                      style: headerStyle(),
                                    ),
                                    Text(
                                      transferData[index]
                                              ["payment_req_status"] ??
                                          "N/A",
                                      style: subStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  transferData[index]["status"] ?? "N/A",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(transferData[index]
                                        ["inserted_date_time"]))
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          if (transferData[index]["transfer_id"] == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("This transfer was not initated"),
                            ));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TransferDetail(
                                        transferData[index]["transfer_id"])));
                          }
                        },
                      );
                    })
                : Center(
                    child: Text("No Transfers Request"),
                  ));
  }
}
