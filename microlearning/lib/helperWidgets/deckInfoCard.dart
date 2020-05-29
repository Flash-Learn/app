import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/classes/flashCard.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';

Widget deckInfoCard(String deckID){

  // TODO: get deck from deckID
  Deck deck = getDeckFromID(deckID);

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
              Row(
                children: <Widget>[
                  for (var tag in deck.tagsList) 
                    Text(
                      tag + " ",
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}
