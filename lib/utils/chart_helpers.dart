import 'package:kryptokafe/utils/enums.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'dart:ui';

import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/utils/painter_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';

class ChartMarkers implements IMarker {
  Entry _entry;
  // ignore: unused_field
  Highlight _highlight;
  double _dx = 0.0;
  double _dy = 0.0;

  var markerLabel;
  Color _textColor;
  Color _backColor;
  double _fontSize;

  ChartMarkers({Color textColor, Color backColor, double fontSize})
      : _textColor = textColor,
        _backColor = backColor,
        _fontSize = fontSize {
    this._textColor ??= Colors.white;
//    _backColor ??= Color.fromARGB((_textColor.alpha * 0.5).toInt(),
//        _textColor.red, _textColor.green, _textColor.blue);
    this._backColor ??= Colors.lightBlue;
    this._fontSize ??= 16.0;
  }

  @override
  void draw(Canvas canvas, double posX, double posY) {
    TextPainter painter = PainterUtils.create(null,
        Utils().chartMoneyFormatter(_entry.y, "\$"), _textColor, _fontSize);
    Paint paint = Paint()
      ..color = _backColor
      ..strokeWidth = 2
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    MPPointF offset = getOffsetForDrawingAtPoint(posX, posY);

    canvas.save();

    painter.layout();
    Offset pos = calculatePos(
        posX + offset.x, posY + offset.y, painter.width, painter.height);
    canvas.drawRRect(
        RRect.fromLTRBR(pos.dx - 5, pos.dy - 5, pos.dx + painter.width + 5,
            pos.dy + painter.height + 5, Radius.circular(5)),
        paint);
    painter.paint(canvas, pos);
    canvas.restore();
  }

  Offset calculatePos(double posX, double posY, double textW, double textH) {
    return Offset(posX - textW / 2, posY - textH / 2);
  }

  @override
  MPPointF getOffset() {
    return MPPointF.getInstance1(_dx, _dy);
  }

  @override
  MPPointF getOffsetForDrawingAtPoint(double posX, double posY) {
    return getOffset();
  }

  @override
  void refreshContent(Entry e, Highlight highlight) {
    _entry = e;
    highlight = highlight;
  }
}

class XAxisValueFormatter extends ValueFormatter {
  TimePeriod timePeriod;

  XAxisValueFormatter(TimePeriod timePeriod) {
    this.timePeriod = timePeriod;
  }

  @override
  String getFormattedValue1(double value) {
    var df;
    switch (timePeriod) {
      case TimePeriod.oneHour:
        df = DateFormat.jm();
        break;
      case TimePeriod.oneDay:
        df = DateFormat.j();
        break;
      case TimePeriod.oneWeek:
        df = DateFormat.MMMd();
        break;

      case TimePeriod.oneMonth:
        df = DateFormat.MMMd();
        break;

      case TimePeriod.sixMonth:
        df = DateFormat.yMMM();
        break;
      case TimePeriod.oneYear:
        df = DateFormat.yMMM();
        break;
    }
    var label = df.format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
    // print(label.toString());
    return label;
  }
}
