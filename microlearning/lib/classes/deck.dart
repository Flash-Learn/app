import 'package:microlearning/classes/flashCard.dart';
import 'package:microlearning/classes/userclass.dart';

class Deck{
  String deckID;
  List<String> flashCardList; // stores a list of flashcards using their ID
  String tagsList;
  User author;
  bool isPublic;
  String deckName;

  Deck({this.deckName,
        this.tagsList,
        this.isPublic,
        this.flashCardList})
  {
    // TODO: add to database

    // TODO: create a copy of each flashcard in flashCard list and and save them i database
  }

  // TODO: deletion of deck
}