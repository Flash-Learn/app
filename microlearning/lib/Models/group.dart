import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupData {
  String groupID;
  String description;
  String name;
  List<String> decks;
  List<String> users;
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

  CollectionReference groupCollection = Firestore.instance.collection('groups');

  DocumentReference groupRef = await groupCollection.add({
    "decks": [],
    "description": "",
    "name": "",
    "users": [uid],
  });
  newGroup.groupID = groupRef.documentID;
  await groupCollection.document(newGroup.groupID).updateData({
    "groupID": newGroup.groupID,
  });
  return newGroup;
}
