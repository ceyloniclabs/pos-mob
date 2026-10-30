import 'package:flutter/material.dart';

class AppTextFieldTheme {
  AppTextFieldTheme._();

  static InputDecorationTheme lightTextFieldTheme = const InputDecorationTheme(
    border: OutlineInputBorder(),
    labelStyle: TextStyle(
      fontSize: 11,
      color: Colors.black,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),
    hintStyle: TextStyle(
      fontSize: 11,
      color: Colors.grey,
    ),
  );

  static InputDecorationTheme darkTextFieldTheme = const InputDecorationTheme(
    border: OutlineInputBorder(),
    labelStyle: TextStyle(
      fontSize: 11,
      color: Colors.white,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 12,
      color: Colors.white,
    ),
  );
}
