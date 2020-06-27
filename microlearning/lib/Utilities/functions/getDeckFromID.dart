import 'package:microlearning/Models/deck.dart';

Deck getDeckFromID(String deckID){
  Deck deck = Deck(
    deckName: "deck name",
    tagsList: ["Maths", "coordinate geometry", "circles", "ellipse"],
    isPublic: true,
  );

  return deck;
}