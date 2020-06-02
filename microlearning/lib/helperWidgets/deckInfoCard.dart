import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/classes/flashCard.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget deckInfoCard(String deckID){

  return StreamBuilder(
    stream: Firestore.instance.collection('decks').document(deckID).snapshots(),
    builder: (context, snapshot) {
      print(deckID);
      if(!snapshot.hasData || snapshot.data == null)
        return Text("loading");

      dynamic deck = snapshot.data;
      print(snapshot);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Container(
            height: 80,
            width: 700,
            color: Colors.amber,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      deck["deckName"],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      deck["deckTags"].join(" "),
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

}
