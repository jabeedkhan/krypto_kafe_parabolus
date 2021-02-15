import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/material.dart';

class NoInternetConnection extends StatefulWidget {
  @override
  _NoInternetConnectionState createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/connection_lost.png',
          ),
          Text(
            StringConstants.noInternetConnectionString,
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
}
