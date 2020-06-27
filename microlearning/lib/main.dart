import 'package:microlearning/screens/Decks/playlist_manage.dart';
import 'package:microlearning/screens/Search/search.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/authentication/register.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance(); 
  var email = prefs.getString('email'); 
  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat'
      ),
      routes: {
        '/': (context) => email == null ? LoginUser() : MyDecks(),
        '/home': (context) => MyDecks(),
        '/register': (context) => RegisterUser(),
        '/search': (context) => Search(),
        '/playlistmanage': (context) => PlayListManage(),
      },
    )
  );
}
