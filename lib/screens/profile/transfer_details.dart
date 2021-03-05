import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kryptokafe/utils/http_url.dart';
import 'dart:convert';
import 'package:kryptokafe/utils/utils.dart';

class TransferDetail extends StatefulWidget {
  final transferID;
  TransferDetail(this.transferID);

  @override
  _TransferDetailState createState() => _TransferDetailState();
}

class _TransferDetailState extends State<TransferDetail> {
  bool isLoading = true, isDataAvailable = true;
  Utils utils;
  Map transferData;

  TableRow buildTableRow(name, value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 8.0, 10.0, 8.0),
        child: Text(
          name,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 20.0, 8.0),
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

  @override
  void initState() {
    super.initState();
    getTransferDetails();
  }

  getTransferDetails() async {
    var requestBody, jsonData;
    requestBody = {"transferId": widget.transferID};
    try {
      var response = await http.post(HttpUrl.GET_TRANSFER_DETAIL,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body);
        if (jsonData["error"] == "false") {
          setState(() {
            transferData = jsonData['data'];
            isLoading = false;
            isDataAvailable = true;
          });
        } else {
          setState(() {
            isLoading = false;
            isDataAvailable = false;
          });
          utils.displayToast(jsonData['message'], context);
        }
      } else {
        utils.displayToast(jsonData['message'], context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Transfer Details", style: TextStyle(color: Colors.black)),
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Table(
              children: [
                buildTableRow("Transfer ID", transferData['id']),
                buildTableRow("Status", transferData['status']),
                buildTableRow("Message", transferData['message'] ?? 'N/A'),
                buildTableRow(
                    "Source Amount", transferData['sourceAmount'].toString()),
                buildTableRow(
                    "Source Currency", transferData['sourceCurrency']),
                buildTableRow("Source Address", transferData['source']),
                buildTableRow(
                    "Dest Amount", transferData['destAmount'].toString()),
                buildTableRow("Dest Currency", transferData['destCurrency']),
                buildTableRow("Dest Address", transferData['dest']),
                buildTableRow(
                    "Fees",
                    transferData['fees']['USDC'] == null
                        ? '0'
                        : transferData['fees']['USDC'].toString()),
                buildTableRow(
                    "Total Fees", transferData['totalFees'].toString()),
                buildTableRow(
                    "Failure Reason", transferData['failureReason'] ?? "N/A"),
              ],
            ),
    );
  }
}
