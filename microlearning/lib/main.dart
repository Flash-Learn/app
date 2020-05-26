import 'package:flutter/material.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/authentication/register.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance(); 
  var email = prefs.getString('email'); 
  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => email == null ? LoginUser() : MyDecks(),
        '/home': (context) => MyDecks(),
        '/register': (context) => RegisterUser(),
      },
    )
  );
}
