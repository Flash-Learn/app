import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseServices {
  final String uid;
  DataBaseServices({this.uid});

  final CollectionReference db = Firestore.instance.collection('user_data');

  Future uploadData(String name, String grade, String gender) async {
    return await db.document(uid).setData({
      'name': name,
      'grade': grade,
      'gender': gender,
      'decks': [],
      'uid': uid,
    });
  }

  Future addDeck(String deckID) async {
    List<String> obj = [deckID];
    return await db.document(uid).updateData({
      'decks': FieldValue.arrayUnion(obj),
    });
  }

  Future removeDeck(String deckID) async {
    List<String> obj = [deckID];
    return await db.document(uid).updateData({
      'decks': FieldValue.arrayRemove(obj),
    });
  }

  Future updateData(String name, String grade, String gender) async {
    QuerySnapshot qs = await db.where('uid', isEqualTo: uid).getDocuments();
    return await db.document(uid).setData({
      'name': name,
      'grade': grade,
      'gender': gender,
      'uid': qs.documents[0].data['uid'],
      'decks': qs.documents[0].data['decks'],
    });
  }

  Future<List<String>> getData() async {
    QuerySnapshot qs;
    try {
      qs = await db.where('uid', isEqualTo: uid).getDocuments();
    } catch (e) {
      print(e);
      return null;
    }
    print(qs.toString());
    if (qs.documents.length == 0) {
      return ['data not present'];
    } else {
      return [
        qs.documents[0].data['name'].toString(),
        qs.documents[0].data['grade'].toString(),
        qs.documents[0].data['gender'].toString()
      ];
    }
  }
}
