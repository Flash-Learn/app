import 'package:microlearning/classes/flashCard.dart';
import 'package:microlearning/classes/userclass.dart';

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
