// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:microlearning/screens/authentication/login.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat'
      ),
      routes: {
        '/': (context) => Login()
      },
    )
  );
}
