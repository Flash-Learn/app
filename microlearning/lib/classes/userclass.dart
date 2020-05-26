
class User {
  final username;
  final email;
  final uid;
  List<String> deckIDs; // list of the decks saved by the user
  User({this.username, this.email, this.uid});
}
