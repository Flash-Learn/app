import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Deck{
  String deckID;
  List<dynamic> flashCardList=[]; // stores a list of flashcards using their ID
  List<dynamic> tagsList=[];
//  User author;
  bool isPublic;
  String deckName;

  Deck({this.deckName,
        this.tagsList ,
        this.isPublic,
  });

  void addFlashcardByID(String flashID){
    flashCardList.insert(flashCardList.length, flashID);

    //TODO: and save to database
  }

  // TODO: constructor to copy deck from other user

  // TODO: deletion of deck
}


Future<void> deleteDeck(String deckID) async{

  print("called delete deck");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.get("uid");
  DocumentReference deckDocument =  Firestore.instance.collection("deck").document(deckID);

//  List<String> flashcardList;

  dynamic deckData = await deckDocument.get();

  print(deckData.documentID);

//  deckDocument.get().then((documentSnapshot) async {
//    print("deleting flashcards");
//
//    if(documentSnapshot.exists){
//      List<String> flashcards = await documentSnapshot.data["flashcardList"];
//      flashcards.forEach((flashcardID) async {
//        await deleteFlashcard(flashcardID);
//      });
//    }
//
//    else {
//      print("erororororor");
//    }
//
//  });
  await deckDocument.delete();

  await Firestore.instance.collection("user_data").document(uid).updateData({
    "decks": FieldValue.arrayRemove([deckID]),
  });
}


Future<Deck> createNewBlankDeck(String userID) async {

  // newDeck is the deck which will be returned
  Deck newDeck = Deck(
    deckName: "",
    tagsList: [],
    isPublic: true,
  );

  // add a new blank deck to the database
  DocumentReference deckRef = await Firestore.instance.collection("decks").add({
    "deckName": "",
    "tagsList": [],
    "flashcardList": [],
    "isPublic": true,
    "deckNameLowerCase": ""
  });

  newDeck.deckID = deckRef.documentID;

  await Firestore.instance.collection("decks").document(newDeck.deckID).updateData({
    "deckID": newDeck.deckID,
  });

  await Firestore.instance.collection("user_data").document(userID).updateData({
    "decks": FieldValue.arrayUnion([newDeck.deckID]),
  });

  return newDeck;
}