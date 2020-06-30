import 'package:flutter/material.dart';

class MyColorScheme
{

  // Colors go in increasing order of darkness

  static Color uno() => Color.fromRGBO(255, 255, 255, 1);

  static Color dos() => Color.fromRGBO(248 , 248, 248, 1);

  static Color tres() => Color.fromRGBO(132, 132, 132, 1);

  static Color quatro() => Color.fromRGBO(61, 61, 61, 1);

  static Color cinco() => Color.fromRGBO(0, 0, 0, 1);

  static Color accent() => Colors.blue[700];
  static Color accentLight() => Colors.blue[400];
  static Color flashcardColor() => Colors.white;
}