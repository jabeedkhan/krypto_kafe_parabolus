import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  PrimaryButton(this.buttonMapData, this.onPressed);
  final Map buttonMapData;
  final GestureTapCallback onPressed;
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(
          horizontal: widget.buttonMapData['horizontalPadding'],
          vertical: widget.buttonMapData['verticalPadding'],
        ),
        child: Text(
          widget.buttonMapData['data'],
          style: TextStyle(
              fontSize: widget.buttonMapData['fontSize'],
              fontWeight: FontWeight.w400,
              color: Colors.white),
        ),
        onPressed: widget.onPressed);
  }
}
