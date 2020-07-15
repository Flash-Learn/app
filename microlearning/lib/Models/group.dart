import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deck.dart';

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

Future addGrouptoUser(String grpID, String uidToBeAdded) async {
  await Firestore.instance
      .collection("user_data")
      .document(uidToBeAdded)
      .updateData({
    "groups": FieldValue.arrayUnion([grpID]),
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
  await Firestore.instance.collection("groups").document(groupID).updateData({
    "users": FieldValue.arrayRemove([uid]),
  });
}

Future<void> deleteGroup(String groupID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.get("uid");
  DocumentReference deckDocument =
      Firestore.instance.collection("groups").document(groupID);

  await deckDocument.delete();

  await Firestore.instance.collection("user_data").document(uid).updateData({
    "groups": FieldValue.arrayRemove([groupID]),
  });
}

Future<Deck> addDeckToGroup(String groupID, {deckName: ""}) async {
  // newDeck is the deck which will be returned
  Deck newDeck = Deck(
    deckName: deckName,
    tagsList: [],
    isPublic: false,
    flashCardList: [],
  );

  // add a new blank deck to the database
  DocumentReference deckRef = await Firestore.instance.collection("decks").add({
    "deckName": deckName,
    "tagsList": [],
    "flashcardList": [],
    "isPublic": false,
    "downloads": 0,
  });

  newDeck.deckID = deckRef.documentID;

  await Firestore.instance
      .collection("decks")
      .document(newDeck.deckID)
      .updateData({
    "deckID": newDeck.deckID,
  });

  await Firestore.instance.collection("groups").document(groupID).updateData({
    "decks": FieldValue.arrayUnion([newDeck.deckID]),
  });

  return newDeck;
}

Future<void> deleteDeckFromGroup(String deckID, String grpID) async {
  DocumentReference deckDocument =
      Firestore.instance.collection("decks").document(deckID);

  dynamic deckData = await deckDocument.get();

  await deckDocument.delete();
  print('lmao lol $grpID');

  await Firestore.instance.collection("groups").document(grpID).updateData({
    "decks": FieldValue.arrayRemove([deckID]),
  });
}
