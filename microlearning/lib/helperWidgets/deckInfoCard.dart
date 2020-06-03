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
        return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            );

      dynamic deck = snapshot.data;
      print(snapshot);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Container(
            height: 100,
            width: 700,
            color: Color.fromRGBO(197, 123, 87, 1),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      deck["deckName"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      deck["tagsList"].join(" "),
                      style: TextStyle(
                        color: Colors.white70,
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
