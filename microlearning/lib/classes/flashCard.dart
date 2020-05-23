class FlashCard {
  String flashCardID;
  String term;
  String definition;

  FlashCard({
    this.term,
    this.definition
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