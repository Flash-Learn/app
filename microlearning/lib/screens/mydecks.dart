import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/deckInfoCard.dart';
import 'package:microlearning/screens/accountsettings.dart';
import 'package:microlearning/screens/editdeck.dart';
import 'package:microlearning/screens/viewDeck.dart';
import 'package:microlearning/helperFunctions/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDecks extends StatelessWidget {
  // TODO: "provide" User class object using provider
//  final String userID = "nYpP671cwaWw5sL04gx9GrXDU6i1";


  // TODO: make method to get list of deck ID of user

  String uid;

  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
    return deckInfoCard(deckID);
  }

  @override
  Widget build(BuildContext context) {
//    if(userID==null)
//      return Container();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(237, 184, 139,1),
//            Color.fromRGBO(129,4,203,1),
            Color.fromRGBO(250, 216, 214,1),
          ],
        ),
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add,),
          onPressed: () async{
            Deck newDeck = Deck(
              deckName: "",
              tagsList: [],
              isPublic: true,
            );
            
            DocumentReference deckRef = await Firestore.instance.collection("decks").add({
              "deckName": "",
              "tagsList": [],
              "isPublic": true,
            });

            newDeck.deckID = deckRef.documentID;

            await Firestore.instance.collection("decks").document(newDeck.deckID).updateData({
              "deckID": newDeck.deckID,
            });

            await Firestore.instance.collection("user_data").document(uid).updateData({
              "decks": FieldValue.arrayUnion([newDeck.deckID]),
            });

            Navigator.of(context).push(MaterialPageRoute(builder: (context){return EditDecks(deck: newDeck);}));
          },
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromRGBO(23, 190, 187, 1),
            centerTitle: true,
            title: Text('FlashLearn'),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/search',
                  );
                },
              ),
            ],
            leading: IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AccountSettings();
                    },
                  ),
                );
              },
            )),
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if(!snapshot.hasData)
              return Text("loading");
            print("user id is ${snapshot.data.getString('uid')}");
            final String userID = snapshot.data.getString('uid');
            uid = userID;
            return StreamBuilder(
                stream: Firestore.instance.collection('user_data').document(userID).snapshots(),
                builder: (context, snapshot){
                  print(userID);
                  if(!snapshot.hasData)
                    return Text("loading");
                  if(snapshot.data==null)
                    return Container();
                  final List<dynamic> userDeckIDs = snapshot.data["decks"];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ListView.builder(
                      itemCount: userDeckIDs.length,
                      itemBuilder: (BuildContext ctxt, int index) => InkWell(
                          onTap: () {
                            print(userDeckIDs[index]);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDeck(
                                    deckID: userDeckIDs[index],
                                  ),
                                ));
                          },
                          child: buildDeckInfo(ctxt, userDeckIDs[index])),
                    ),
                  );

                }
            );
          }
        ),




      ),
    );
  }
}
