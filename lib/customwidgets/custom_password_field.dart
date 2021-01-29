import 'package:flutter/material.dart';
import 'package:kryptokafe/utils/apptheme.dart';

class CustomPasswordField extends StatefulWidget {
  CustomPasswordField(this.passwordData);
  final Map passwordData;
  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          keyboardType: widget.passwordData['keyboardType'],
          controller: widget.passwordData['controller'],
          autofocus: widget.passwordData['autofocus'],
          minLines: widget.passwordData['minLines'],
          obscureText: obscureText,
          textCapitalization: widget.passwordData["textCapitalization"],
          textInputAction: widget.passwordData['textInputAction'],
          maxLength: widget.passwordData["maxLength"],
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: widget.passwordData['inputFontSize'],
              fontWeight: FontWeight.w400),
          decoration: InputDecoration(
              hintText: widget.passwordData["hintText"],
              hintStyle: TextStyle(color: Color(AppTheme.gray6)),
              counterText: widget.passwordData["counterText"],
              errorStyle: TextStyle(color: Colors.blue)),
          validator: widget.passwordData['validator'],
          focusNode: widget.passwordData['focusNode'],
          onFieldSubmitted: widget.passwordData['onFieldSubmitted'],
        ),
        Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: obscureText
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
              splashColor: Colors.transparent,
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            ))
      ],
    );
  }
}
