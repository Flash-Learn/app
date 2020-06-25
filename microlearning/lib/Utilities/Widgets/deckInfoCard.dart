import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Container(
            height: 100,
            width: 300,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              color: MyColorScheme.uno(),
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.filter_none,
                              color: MyColorScheme.accent(),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              deck["deckName"],
                              style: TextStyle(
                                  color: MyColorScheme.cinco(),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.bookmark,
                              color: MyColorScheme.accent(),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              deck["tagsList"].join(" "),
                              style: TextStyle(
                                color: MyColorScheme.quatro(),
                              ),
                            ),
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
