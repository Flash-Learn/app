import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';

class ViewDeck extends StatefulWidget {
  final String deckID;
  ViewDeck({Key key, @required this.deckID}) : super(key: key);
  @override
  _ViewDeckState createState() => _ViewDeckState(deckID: deckID);
}

class _ViewDeckState extends State<ViewDeck> {
  String deckID;
  Deck deck;
  _ViewDeckState({this.deckID});
  @override
  void initState(){
    deck = _getThingsOnStartup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          deckID,
        ),
      ),
    );
  }
  Deck _getThingsOnStartup(){
    Deck deck = getDeckFromID(deckID);
    return deck;
  }
}