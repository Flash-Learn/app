import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';

Widget deckInfoCard(String deckID){
  Deck deck = Deck(
    deckName: "deck name",
    tagsList: "tag1 tag2 tag3",
    isPublic: true,
  );

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
              Text(
                deck.tagsList,
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