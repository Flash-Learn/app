import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';

class ViewDeck extends StatelessWidget {

  final String deckID;
  ViewDeck({Key key, @required this.deckID}) : super(key: key);

  Deck deck = getDeckFromID(deckID);

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
}
