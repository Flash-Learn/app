import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/flashcard.dart';

Future<void> updateFlashcardList(Deck deck, List<FlashCard> flashCardData) async {

  // NOTE: flashCardData is 1 indexed and flashCardList is 0 indexed.

  int initialLength = deck.flashCardList.length, newLength = flashCardData.length;

  print("$initialLength $newLength");

  final CollectionReference deckReference = Firestore.instance.collection("decks");
  final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");

  if(newLength >= initialLength){
    for(var i=0; i<initialLength; i++){
      var j=i;
      flashcardReference.document(deck.flashCardList[i]).updateData({
        'term': flashCardData[j].term,
        'definition': flashCardData[j].definition,
        'isTermPhoto': flashCardData[j].isTermPhoto,
        'isDefinitionPhoto': flashCardData[j].isDefinitionPhoto,
        'isOneSided': flashCardData[j].isOneSided
      });
    }

    for(var i=initialLength; i<newLength; i++){
      var j=i;
      dynamic flashRef = await flashcardReference.add({
        'term': flashCardData[j].term,
        'definition': flashCardData[j].definition,
        'isTermPhoto': flashCardData[j].isTermPhoto,
        'isDefinitionPhoto': flashCardData[j].isDefinitionPhoto,
        'isOneSided': flashCardData[j].isOneSided
      });

      await deckReference.document(deck.deckID).updateData({
        'flashcardList': FieldValue.arrayUnion([flashRef.documentID]),
      });
    }
  }

  else{
    for(var i=0; i<newLength; i++){
      var j=i;
      await flashcardReference.document(deck.flashCardList[i]).updateData({
        'term': flashCardData[j].term,
        'definition': flashCardData[j].definition,
        'isTermPhoto': flashCardData[j].isTermPhoto,
        'isDefinitionPhoto': flashCardData[j].isDefinitionPhoto,
        'isOneSided': flashCardData[j].isOneSided
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