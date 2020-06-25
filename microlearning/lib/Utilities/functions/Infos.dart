import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future updateInfo(dynamic context, dynamic data) async {
  DataBaseServices here = DataBaseServices(uid: data['_uid']);
  await here.updateData(data['_name'], data['_grade'], data['_gender']);
  Navigator.pop(context);
}

Future enterInfo(dynamic context, dynamic data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uid');
  
  DataBaseServices here = DataBaseServices(uid: uid);
  here.uploadData(data['_name'], data['_grade'], data['_gender']);

  Future.delayed(Duration.zero, ()
  {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) {
      return MyDecks(isdemo: true,);
    }));
  });
}