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
        this.tagsList ,
        this.isPublic,
  });

  // TODO: constructor to copy deck from other user

  // TODO: deletion of deck
}