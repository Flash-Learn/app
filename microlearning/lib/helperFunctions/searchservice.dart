import 'package:cloud_firestore/cloud_firestore.dart';


//Talking with the database and getting the deck name.
// Check once by adding a deckName which starts with a lowercase letter and see if the search still works.
// Line 12 should do the job but if it does not, might have to ensure that the deckname starts with a capital letter.
class SearchService {
  searchByName(String searchField) {
    return Firestore.instance
    .collection('decks')
    .where('searchKey',
    isEqualTo: searchField.substring(0, 1).toLowerCase())
    .getDocuments();

  }
}