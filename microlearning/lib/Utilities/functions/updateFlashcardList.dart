import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';

Future<void> updateFlashcardList(Deck deck, List<List<String>> flashCardData) async {

  // NOTE: flashCardData is 1 indexed and flashCardList is 0 indexed.

//  bool res = flashCardData.remove(flashCardData[1]);

  int initialLength = deck.flashCardList.length, newLength = flashCardData.length-1;

  print("$initialLength $newLength");

  final CollectionReference deckReference = Firestore.instance.collection("decks");
  final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");

  if(newLength >= initialLength){
    for(var i=0; i<initialLength; i++){
      var j=i+1;
      flashcardReference.document(deck.flashCardList[i]).updateData({
        'term': flashCardData[j][0],
        'definition': flashCardData[j][1],
        'isimage': flashCardData[j][2],
      });
    }

    for(var i=initialLength; i<newLength; i++){
      var j=i+1;
      dynamic flashRef = await flashcardReference.add({
        'term': flashCardData[j][0],
        'definition': flashCardData[j][1],
        'isimage': flashCardData[j][2],
      });

      await deckReference.document(deck.deckID).updateData({
        'flashcardList': FieldValue.arrayUnion([flashRef.documentID]),
      });
    }
  }

  else{
    for(var i=0; i<newLength; i++){
      var j=i+1;
      await flashcardReference.document(deck.flashCardList[i]).updateData({
        'term': flashCardData[j][0],
        'definition': flashCardData[j][1],
        'isimage': flashCardData[j][2]
      });
    }

    for(var i=newLength; i<initialLength; i++){
      print("deleting elements");

      await deckReference.document(deck.deckID).updateData({
        "flashcardList": FieldValue.arrayRemove([deck.flashCardList[i]]),
      });

      flashcardReference.document(deck.flashCardList[i]).delete();
    }
  }

}