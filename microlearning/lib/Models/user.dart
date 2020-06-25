class User {
  final String username;
  final String email;
  final String uid;
  List<String> deckIDs; // list of the decks saved by the user
  User({this.username, this.email, this.uid});
}
