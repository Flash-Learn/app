import 'package:flutter/material.dart';

inputTextDecorations(String labelText) => InputDecoration(
                          labelText: labelText,
                          labelStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(20.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),                          
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                          ),
);