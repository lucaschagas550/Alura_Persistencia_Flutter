import 'package:flutter/material.dart';

final bytebankTheme = ThemeData(
  primaryColor: Colors.green[900],
  colorScheme: ColorScheme.light(primary: Colors.green.shade900),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green[700],
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.green[700],
    ),
  ),
);
