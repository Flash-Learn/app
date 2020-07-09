import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupData {
  String groupID;
  String description;
  String name;
  List<dynamic> decks;
  List<dynamic> users;
  GroupData({
    this.groupID,
    this.description,
    this.name,
    this.decks,
    this.users,
  });
}

Future<GroupData> createNewGroup(String uid) async {
  GroupData newGroup = GroupData(
    name: "",
    description: "",
    decks: [],
    users: [],
  );

  newGroup.users.add(uid);

  CollectionReference groupCollection = Firestore.instance.collection('groups');

  DocumentReference groupRef = await groupCollection.add({
    "decks": [],
    "description": "",
    "name": "",
    "users": newGroup.users,
  });
  newGroup.groupID = groupRef.documentID;
  await groupCollection.document(newGroup.groupID).updateData({
    "groupID": newGroup.groupID,
  });

  CollectionReference userCollection =
      Firestore.instance.collection('user_data');

  List<String> obj = [newGroup.groupID];

  await userCollection
      .document(uid)
      .updateData({"groups": FieldValue.arrayUnion(obj)});
  return newGroup;
}

Future updateGroupData(GroupData groupData) async {
  CollectionReference groupCollection = Firestore.instance.collection('groups');
  await groupCollection.document(groupData.groupID).updateData({
    "decks": groupData.decks,
    "name": groupData.name,
    "users": groupData.users,
    "description": groupData.description,
  });
}

Future<void> leaveGroup(String groupID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.get("uid");
//  DocumentReference deckDocument =
//  Firestore.instance.collection("groups").document(groupID);

//  await deckDocument.delete();

  await Firestore.instance.collection("user_data").document(uid).updateData({
    "groups": FieldValue.arrayRemove([groupID]),
  });
}
