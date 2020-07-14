import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future updateInfo(dynamic data) async {
  DataBaseServices here = DataBaseServices(uid: data['_uid']);
  await here.updateData(data['_name'], data['_grade'], data['_gender']);
}

Future enterInfo(dynamic context, dynamic data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uid');
  String email = prefs.getString('email');

  DataBaseServices here = DataBaseServices(uid: uid);
  here.uploadData(data['_name'], data['_grade'], data['_gender'], email);

  Future.delayed(Duration.zero, () {
    return Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) {
      return MyDecks(
        isdemo: true,
      );
    }), (Route<dynamic> route) => false);
  });
}
