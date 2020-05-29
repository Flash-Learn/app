import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/classes/flashCard.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';

Widget deckInfoCard(String deckID){
<<<<<<< HEAD
  Deck deck = Deck(
    deckName: "deck name",
    tagsList: ["tag1", "tag2", "tag3"],
    isPublic: true,
  );
=======

  // TODO: get deck from deckID
  Deck deck = getDeckFromID(deckID);
>>>>>>> upstream/develop

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      child: Container(
        height: 80,
        width: 700,
        color: Colors.amber,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text(
                  deck.deckName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
              ),
              for(var item in deck.tagsList) Text(
                item,
                style: TextStyle(
                  color: Colors.black38,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}