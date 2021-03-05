import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kryptokafe/screens/home.dart';

class TransferComplete extends StatefulWidget {
  final transferData;
  TransferComplete(this.transferData);

  @override
  _TransferCompleteState createState() => _TransferCompleteState();
}

class _TransferCompleteState extends State<TransferComplete> {
  String coinCode, destAddress;
  var createdDate;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  TimeOfDay createdTime;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() {
    coinCode = widget.transferData['data']['destCurrency'];
    destAddress = widget.transferData['data']['dest'];
    destAddress = destAddress.substring(
      destAddress.indexOf(":") + 1,
    );

    createdDate = DateTime.fromMillisecondsSinceEpoch(
        widget.transferData['data']['createdAt']);
    createdTime = TimeOfDay.fromDateTime(createdDate);
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home(1)),
        (Route<dynamic> route) => false);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              minRadius: 30.0,
              child: Icon(
                Icons.done_rounded,
                size: 30.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Your transfer of ${widget.transferData['data']["destAmount"].toString()}  $coinCode has been initiated at $createdDate , ${createdTime.toString()}",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            //  Text(widget.transferData['data']['sd']),
            Table(
              children: [
                buildTableRow(
                    "Transfer Status", widget.transferData['data']['status']),
                buildTableRow(
                    "Transfered Amount",
                    widget.transferData['data']["destAmount"].toString() +
                        " " +
                        coinCode),
                buildTableRow("Sent To", destAddress),
                buildTableRow(
                    "Fees",
                    widget.transferData['data']['totalFees'].toString() +
                        " " +
                        coinCode),
                buildTableRow(
                    "Transaction ID", widget.transferData['data']['id'])
              ],
            ),
            SizedBox(height: 30.0),
            FlatButton(
              child: Text(
                "CLOSE",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Home(1)),
                    (Route<dynamic> route) => false);
              },
            ),
            SizedBox(height: 20.0),
            Text(
                "Please check for the status of the transaction in Transaction History")
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(name, value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
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
