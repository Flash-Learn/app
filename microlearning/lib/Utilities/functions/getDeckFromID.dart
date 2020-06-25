import 'package:microlearning/Models/deck.dart';

Deck getDeckFromID(String deckID){
  Deck deck = Deck(
    deckName: "deck name",
    tagsList: ["Maths", "coordinate geometry", "circles", "ellipse"],
    isPublic: true,
  );

  // all this is temporary
  deck.addFlashcardByID("sdfasdf");
  deck.addFlashcardByID("flash card 2");
  deck.addFlashcardByID("fasf");
  deck.addFlashcardByID("fasf safa asd f");

  return deck;
}