import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

inputTextDecorations(String labelText) => InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: Colors.grey),
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.all(20.0),
    enabledBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: MyColorScheme.accentLight(), width: 2.0),
    ),                          
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: MyColorScheme.accent(), width: 2.0),
    ),
);