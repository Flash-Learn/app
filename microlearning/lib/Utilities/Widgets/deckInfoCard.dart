import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';



Widget deckInfoCard(String deckID) {

  List<Widget> getTags(List<dynamic> strings)
  {
    List<Widget> ret = [];
    for(var i = 0; i < strings.length; i++){
      ret.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: (i%2 == 0) ? Color.fromRGBO(242, 201, 76, 1) : Color.fromRGBO(187, 107, 217, 1),
            ),
//            color: Color.fromRGBO(242, 201, 76, 1),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                strings[i],
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  fontSize: 15,
                ),
              ),
            ),
          )
      );
      ret.add(SizedBox(width: 5,));
    }
    return ret;
  }


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
            width: MediaQuery. of(context). size. width,
            child: Material(
              elevation: 3,
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
//                            Icon(
//                              Icons.filter_none,
//                              color: MyColorScheme.accent(),
//                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              deck["deckName"],
                              style: TextStyle(
                                  color: MyColorScheme.cinco(),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900
                              ),
                                  overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )),
                    SizedBox(height: 5,),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
//                            Icon(
//                              Icons.bookmark,
//                              color: MyColorScheme.accent(),
//                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: getTags(deck["tagsList"]),
                            )
//                            Text(
//                              deck["tagsList"].join(" "),
//                              style: TextStyle(
//                                color: MyColorScheme.quatro(),
//                              ),
//                            ),
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
