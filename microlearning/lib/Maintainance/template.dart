import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STORE ERRORS THAT YOU MIGHT WANT TO DISPLAY IN THE APP HERE
  String err;

  // MAINTAINANCE CODE GOES HERE

  // PASSING THE ERROR INTO THE APP
  return runApp(MyApp(err: err));
}

class MyApp extends StatelessWidget {
  final String err;
  MyApp({this.err});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Maintainance"),
        ),
        body: Center(child: Text("Erros: " + err)),
      ),
    );
  }
}
