import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCard {
  String flashCardID;
  String term;
  String definition;
  bool isTermPhoto;
  bool isDefinitionPhoto;
  bool isOneSided;

  FlashCard({
    this.term,
    this.definition,
    this.isTermPhoto,
    this.isDefinitionPhoto,
    this.isOneSided,
  }){
    // TODO: add flash card to database
  }

  //implement deletion of flashcard
}

Future<FlashCard> getFlashCardByID(String flashCardID) async{
  // TODO: call database and get flash card with the given ID

  FlashCard ret = FlashCard(term: "term", definition: "definition"); // change with actual database call and use await

  return ret;
}

Future<void> deleteFlashcard(String flashCardID) async{
  await Firestore.instance.collection("deck").document(flashCardID).delete();
}