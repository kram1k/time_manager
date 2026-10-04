import 'package:flutter/material.dart';

abstract final class AppStyle {
  static const boxColor = Colors.black;
  static const innerBoxColor = Color(0xFF212121);
  static const textColor = Color(0xFFADADAD);

  static const font = TextStyle(
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: textColor,
  );

  static const smallFont = TextStyle(
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: textColor,
  );
}
