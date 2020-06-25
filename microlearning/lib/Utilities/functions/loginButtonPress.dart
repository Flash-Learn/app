import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/screens/authentication/init_info.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/services/database.dart';
import 'package:microlearning/services/google_signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future googleLoginButtonPress(dynamic context) async {
  String test =
      await signInWithGoogle(context);
  SharedPreferences prefs =
      await SharedPreferences.getInstance();
  String uid = prefs.getString('uid');
  DataBaseServices here =
      DataBaseServices(uid: uid);
  List<String> defaults =
      await here.getData();
  if (here == null || defaults.length == 1) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return GetUserInfo();
        },
      ),
    );
  } else if (test == null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return LoginUser();
        },
      ),
    );
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return MyDecks();
        },
      ),
    );
  }
}