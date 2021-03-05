import 'package:kryptokafe/utils/apptheme.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  CustomTextfield(this.textData);
  final Map textData;

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: widget.textData['keyboardType'],
      inputFormatters: widget.textData['inputFormatters'],
      controller: widget.textData['controller'],
      autofocus: widget.textData['autofocus'],
      enabled: widget.textData['enabled'],
      minLines: widget.textData['minLines'],
      maxLines: widget.textData['maxLines'],
      obscureText: widget.textData["obscureText"],
      textCapitalization: widget.textData["textCapitalization"],
      textInputAction: widget.textData['textInputAction'],
      maxLength: widget.textData["maxLength"],
      style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: widget.textData['inputFontSize'],
          fontWeight: FontWeight.w400),
      decoration: InputDecoration(
          prefix: widget.textData['prefix'],
          hintText: widget.textData["hintText"],
          hintStyle: TextStyle(color: Color(AppTheme.gray3)),
          counterText: widget.textData["counterText"],
          errorStyle: TextStyle(color: Colors.blue)),
      validator: widget.textData["validator"],
      focusNode: widget.textData['focusNode'],
      onFieldSubmitted: widget.textData['onFieldSubmitted'],
      onChanged: widget.textData['onChanged'],
      onTap: widget.textData['onTap'],
    );
  }
}
