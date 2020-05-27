import 'package:microlearning/classes/deck.dart';

Deck getDeckFromID(){
  Deck deck = Deck(
    deckName: "deck name",
    tagsList: "tag1 tag2 tag3 tag4",
    isPublic: true,
  );

  // all this is temporary
  deck.addFlashcardByID("sdfasdf");
  deck.addFlashcardByID("flash card 2");
  deck.addFlashcardByID("fasf");
  deck.addFlashcardByID("fasf safa asd f");

  return deck;
}