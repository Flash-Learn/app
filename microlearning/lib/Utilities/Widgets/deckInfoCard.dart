import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/functions/getTags.dart';

Widget deckInfoCard(String deckID) {
  return StreamBuilder(
    stream: Firestore.instance.collection('decks').document(deckID).snapshots(),
    builder: (context, snapshot) {
      print(deckID);
      if (!snapshot.hasData || snapshot.data == null)
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Container(
            height: 110,
            width: MediaQuery.of(context).size.width,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              color: MyColorScheme.uno(),
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 35, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              deck["deckName"],
                              style: TextStyle(
                                  color: MyColorScheme.cinco(),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: getTags(deck["tagsList"]),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
