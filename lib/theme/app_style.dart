import 'package:flutter/material.dart';

abstract final class AppStyle {
  static const boxColor = Colors.black;
  static const innerBoxColor = Color(0xFF212121);
  static const textColor = Color(0xFFADADAD);
  static const startColor = Color(
    0xFFEF5350,
  );
  static const endColor = Color(
    0xFF66BB6A,
  );

  static const font = TextStyle(
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: textColor,
  );

  static const smallFont = TextStyle(
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: textColor,
  );
}
