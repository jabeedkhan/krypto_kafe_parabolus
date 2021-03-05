import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/http_url.dart';
import 'dart:convert';
import 'transfer_complete.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/utils/utils.dart';

class ConfirmTransfer extends StatefulWidget {
  final Map transferData;
  ConfirmTransfer(this.transferData);
  @override
  _ConfirmTransferState createState() => _ConfirmTransferState();
}

class _ConfirmTransferState extends State<ConfirmTransfer> {
  String destinationAddress, sourceAddress, coinCode;
  var createdDate;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  TimeOfDay createdTime;
  Connectivity connectivity = Connectivity();
  bool internetStatus = true, loadingProgress = false;

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    _initialize();
  }

  _initialize() {
    coinCode = widget.transferData['data']["destCurrency"];
    String dAddress = widget.transferData['data']["dest"],
        sAddress = widget.transferData['data']["source"];
    dAddress =
        dAddress.substring(dAddress.indexOf(":") + 1, dAddress.length).trim();
    sAddress =
        sAddress.substring(sAddress.indexOf(":") + 1, sAddress.length).trim();

    destinationAddress = dAddress;
    sourceAddress = sAddress;

    createdDate = DateTime.fromMillisecondsSinceEpoch(
        widget.transferData['data']['createdAt']);
    createdTime = TimeOfDay.fromDateTime(createdDate);
  }

  confirmTransfer() async {
    var requestBody, jsonData;
    requestBody = {"transferId": widget.transferData['data']["id"]};
    try {
      var response = await http.post(HttpUrl.CONFIRM_TRANSFER,
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          loadingProgress = false;
        });
        jsonData = jsonDecode(response.body);
        if (jsonData['error'] == 'false') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TransferComplete(jsonData)),
            (route) => false,
          );
        } else {
          Utils().displayToast(jsonData['message'], context);
        }
      } else {
        setState(() {
          loadingProgress = false;
        });
        Utils().displayToast(response.reasonPhrase, context);
      }
    } catch (e) {
      print(e);
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text("Confirm Transfer", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          loadingProgress ? LinearProgressIndicator() : SizedBox(),
          SizedBox(
            height: 10.0,
          ),
          Text(
            widget.transferData['data']["destAmount"].toString() +
                " " +
                coinCode,
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20.0,
          ),
          Table(
            children: [
              buildTableRow(
                  "Transaction ID", widget.transferData['data']["id"]),
              buildTableRow(
                  "Fees",
                  widget.transferData['data']["fees"][coinCode].toString() +
                      " " +
                      coinCode),
              buildTableRow(
                  "Message", widget.transferData['data']["message"] ?? ''),
              buildTableRow("Source", sourceAddress),
              buildTableRow("Destination", destinationAddress),
              buildTableRow(
                  "Created Date", formatter.format(createdDate).toString()),
              buildTableRow("Created Time", createdTime.format(context)),
              buildTableRow("Status", widget.transferData['data']["status"]),
            ],
          ),
          SizedBox(
            height: 40.0,
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                loadingProgress = true;
              });
              confirmTransfer();
            },
            child: Text(
              "CONFIRM",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  TableRow buildTableRow(name, value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 10.0),
        child: Text(
          name,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      )
    ]);
  }
}
