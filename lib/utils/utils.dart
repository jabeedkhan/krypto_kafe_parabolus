import 'package:intl/intl.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  final fullnameRegex = RegExp(r"^(\w.+\s).+");
  final phoneNumberRegex = RegExp(r"^\+?[1-9]\d{1,14}$");
  final emailRegex = RegExp(
    r"[a-z0-9!#$%&'*+\=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|edu|org|net|gov|mil|in|info)\b",
  );
  FToast fToast = FToast();
  static const _locale = 'in';

  formatNumber(String s) {
    return NumberFormat.decimalPattern(_locale).format(int.parse(s));
  }

  String currency(String country) {
    return NumberFormat.compactSimpleCurrency(locale: country).currencySymbol;
  }

  void displayToast(String message, BuildContext context,
      {Color bgcolors, gravity}) {
    if (bgcolors == null) bgcolors = Colors.grey[400].withOpacity(0.9);
    if (gravity == null) gravity = ToastGravity.BOTTOM;
    fToast.init(context);
    fToast.showToast(
      toastDuration: Duration(seconds: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: bgcolors,
        ),
        child: Wrap(
          //  mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ],
        ),
      ),
      gravity: gravity,
    );
  }

  displayDialog({BuildContext context, String title, String message}) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
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

  getDate(date, type, format) {
    date = date.toString();
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(5, 7));
    int dayDate = int.parse(date.substring(8, 10));
    int hour = int.parse(date.substring(11, 13));
    int minute = int.parse(date.substring(14, 16));
    if (type) {
      if (format == "date") {
        return formatDate(
            DateTime(year, month, dayDate), [yyyy, '-', mm, '-', dd]);
      } else if (format == "time") {
        return formatDate(
            DateTime(year, month, dayDate, hour, minute), [HH, ':', nn]);
      } else if (format == 'onlyHour') {
        return formatDate(DateTime(year, month, dayDate, hour, minute), [hh]);
      } else if (format == 'twelveHourDateTime') {
        return formatDate(DateTime(year, month, dayDate, hour, minute),
            [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
      } else {
        return formatDate(DateTime(year, month, dayDate, hour, minute),
            [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
      }
    } else {
      if (format == "date") {
        return formatDate(
            DateTime(year, month, dayDate), [d, ' ', M, ', ', yyyy]);
      } else if (format == "time") {
        return formatDate(DateTime(year, month, dayDate, hour, minute),
            [h, ':', nn, ' ', am]);
      } else if (format == 'onlyHour') {
        return formatDate(DateTime(year, month, dayDate, hour, minute), [hh]);
      } else if (format == 'twelveHourDateTime') {
        return formatDate(DateTime(year, month, dayDate, hour, minute),
            [d, ' ', M, ', ', yyyy, ' ', hh, ':', nn, ':', ss]);
      } else {
        return formatDate(DateTime(year, month, dayDate, hour, minute),
            [d, ' ', M, ', ', yyyy, ' ', h, ':', nn, ' ', am]);
      }
    }
  }

  moneyFormatter(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: ',',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
            compactFormatType: CompactFormatType.long,
          )).output.symbolOnLeft;
    else
      return "N/A";
  }

  moneyFormatterWithSymbolWithCompact(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: ',',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
            compactFormatType: CompactFormatType.long,
          )).output.compactSymbolOnLeft;
    else
      return "N/A";
  }

  moneyFormatterWithOutCompact(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: ',',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
            compactFormatType: CompactFormatType.long,
          )).output.symbolOnLeft;
    else
      return "N/A";
  }

  moneyFormatterWithOutCompactWithOutSymbol(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: '',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
            compactFormatType: CompactFormatType.long,
          )).output.nonSymbol;
    else
      return "N/A";
  }

  moneyFormatterWithOutSymbol(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: ',',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
            compactFormatType: CompactFormatType.long,
          )).output.nonSymbol;
    else
      return "N/A";
  }

  moneyFormatterWithTwoNumbersWithoutSymbolWithoutCompact(value, symbol) {
    if (value != "null")
      return FlutterMoneyFormatter(
          amount: double.parse(value.toString()),
          settings: MoneyFormatterSettings(
            symbol: "\$",
            thousandSeparator: '',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 10,
            compactFormatType: CompactFormatType.long,
          )).output.nonSymbol;
  }

  chartMoneyFormatter(value, symbol) {
    return FlutterMoneyFormatter(
        amount: double.parse(value.toString()),
        settings: MoneyFormatterSettings(
          symbol: "\$",
          thousandSeparator: ',',
          decimalSeparator: '.',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 4,
          compactFormatType: CompactFormatType.long,
        )).output.symbolOnLeft;
  }

  noDataFound(context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.cancel,
            color: Colors.black,
            size: MediaQuery.of(context).size.height / 10.0,
          ),
          Text(
            StringConstants.noDataFoundString,
            style: TextStyle(
              color: Colors.black,
              fontFamily: StringConstants.oxygenFontnameString,
              fontSize: MediaQuery.of(context).size.height / 45.0,
            ),
          )
        ],
      ),
    );
  }

  // signature({url, data}) async {
  //   var preferences = KryptoSharedPreferences();
  //   var dataTosign = data != null ? url + data : url;
  //   var encodedKey =
  //       utf8.encode(await preferences.getString(WyreApi.SECRET_KEY));
  //   var hmacSha256 = Hmac(sha256, encodedKey);
  //   var bytesData = utf8.encode(dataTosign);
  //   var digest = hmacSha256.convert(bytesData);
  //   String token = digest.toString();
  //   return token;
  //   //  CryptoJS.enc.Hex.stringify(CryptoJS.HmacSHA256(dataToBeSigned.toString(CryptoJS.enc.Utf8), YOUR_SECRET_KEY));
  // }

  // signatureBuffer({url, data}) {
  //   var encodedKey = utf8.encode(WyreApi.SECRET_KEY);
  //   var hmacSha256 = Hmac(sha256, encodedKey);
  //   var urlEncoded = utf8.encode(url);
  //   var dataEncoded = utf8.encode(data);
  //   var dataTosign = urlEncoded + dataEncoded;
  //   var digest = hmacSha256.convert(dataTosign);
  //   String token = digest.toString();
  //   return token;
  // }

  progressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red),
    );
  }
}
