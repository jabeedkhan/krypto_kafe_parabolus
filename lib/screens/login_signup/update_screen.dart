import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatefulWidget {
  final url;

  const UpdateScreen({Key key, this.url}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  launchUrl() async {
    if (await canLaunch(widget.url)) {
      await launch(widget.url);
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF070d59), Color(0xFF1f3c88)])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                StringConstants.ImageRocket,
                scale: 2.0,
              ),
              Text("New Update is Available",
                  style: TextStyle(color: Colors.white, fontSize: 27.0)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "The current version of this application is no loger supported please update it from the playstore",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                onPressed: () {
                  launchUrl();
                },
                child: Text(
                  "Update",
                  style: TextStyle(fontSize: 22.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
