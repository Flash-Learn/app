import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataBaseServices {
  
  final String uid;
  DataBaseServices({this.uid});

  final CollectionReference db = Firestore.instance.collection('user_data');

  Future updateData(String name, String grade, String gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String uid = prefs.getString('uid');

    return await db.document(uid).setData({
      'name': name,
      'grade': grade,
      'gender': gender,
      'decks': {},
    });

  }

}