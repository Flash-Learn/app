import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void saveDeck(context, Deck deck) async{
  print("in savedeck");
  Deck toSave = Deck(
    deckName: deck.deckName,
    tagsList: deck.tagsList,
    isPublic: false,
  );
  toSave.isPublic = false;
  toSave.deckID=null;
  toSave.flashCardList=[];

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('uid');
  final CollectionReference decksReference = Firestore.instance.collection("decks");
  final CollectionReference flashcardsReference = Firestore.instance.collection("flashcards");
  final CollectionReference userReference = Firestore.instance.collection("user_data");
  for(var i=0; i<deck.flashCardList.length; i++){
    dynamic tempCard;
    await flashcardsReference.document(deck.flashCardList[i]).get().then((doc) {
      tempCard = doc.data;
    });
    final flashRef = await flashcardsReference.add({
      'term': tempCard["term"],
      'definition': tempCard["definition"],
      'isimage': tempCard["isimage"],
    });
    print(flashRef.documentID);
    toSave.flashCardList.add(flashRef.documentID);
  }

  final deckRef = await decksReference.add({
    'deckName': toSave.deckName,
    'tagsList': toSave.tagsList,
    'flashcardList': toSave.flashCardList,
    'isPublic': false,
  });

  print("deck ID:");
  print(deckRef.documentID);

  userReference.document(userID).updateData({
    'decks': FieldValue.arrayUnion([deckRef.documentID]),
  });

  decksReference.document(deckRef.documentID).updateData({
    'deckID': deckRef.documentID,
  });

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => MyDecks()),
        (Route<dynamic> route) => false,
  );

}