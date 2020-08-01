import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/flashcard.dart';
import 'package:microlearning/Utilities/Widgets/flashcard_side.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/Utilities/functions/getTags.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';

horizontalScrollCards(List<dynamic> flashCardList, String ifGrpThenID, bool belongsToGrp, String deckID){
  return flashCardList.map<Widget>((dynamic data){
    return StreamBuilder(
      stream: Firestore.instance.collection('flashcards').document(data).snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          FlashCard card = FlashCard(definition: snapshot.data["definition"], term: snapshot.data["term"], isDefinitionPhoto: snapshot.data["isDefinitionPhoto"], isOneSided: snapshot.data["isOneSided"], isTermPhoto: snapshot.data["isTermPhoto"]);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal :3.0),
              child: Container(
                decoration: BoxDecoration(color: MyColorScheme.accentLight(),borderRadius: BorderRadius.all(Radius.circular(50.0)), boxShadow: [BoxShadow(color: Colors.black26,)]),
                width: MediaQuery.of(context).size.width*0.2,
                height: MediaQuery.of(context).size.height*0.16,
                child: !snapshot.hasData ? Loading(size: 10) :
                  GestureDetector(
                    onTap: (){
                      return Navigator.push(
                        context,
                        ScaleRoute(
                          page: ViewDeck(
                            deckID: deckID,
                            ifGroupThenGrpID: ifGrpThenID,
                            isDeckforGroup: belongsToGrp,
                            navigationIndex: flashCardList.indexOf(data),
                          ),
                        )
                      );
                    },
                    child: FlashcardSide(content: card.term, isPic: card.isTermPhoto, editAccess: false, isSmallView: true,)
                  ),
              ),
            );
          }else{
          return Loading(size: 10);
        }
      }
    );
  }).toList();
}

getFlashcardAsCards(dynamic data, String ifGrpThenID, bool belongsToGrp, String deckID){
  List<dynamic> flashCardList = data["flashcardList"];
  return flashCardList == null ? Container() : SingleChildScrollView(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
          child: Row(
        children: 
          horizontalScrollCards(flashCardList, ifGrpThenID, belongsToGrp, deckID),
      ),
    ),
  );
}

getNameAndTags(dynamic data){
  List<Widget> children;
  children = getTags(data["tagsList"]);
  children.insert(0, Padding(
    padding: const EdgeInsets.only(right: 5.0),
    child: Text(data["deckName"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
  ),);
  return children;
}

Widget deckInfoCard(String deckID, String ifGrpThenID, bool belongsToGrp) {
  return StreamBuilder(
    stream: Firestore.instance.collection('decks').document(deckID).snapshots(),
    builder: (context, snapshot) {
      print(deckID);
      if (!snapshot.hasData || snapshot.data == null)
        return Center(
          child: SizedBox(
            child: CircularProgressIndicator(),
            width: 30,
            height: 30,
          ),
        );

      dynamic deck = snapshot.data;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: (){
                return Navigator.push(
                  context,
                  ScaleRoute(
                    page: ViewDeck(
                      deckID: deckID,
                      ifGroupThenGrpID: ifGrpThenID,
                      isDeckforGroup: belongsToGrp,
                    ),
                  )
                );
              },
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getNameAndTags(deck),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.16,
            child: getFlashcardAsCards(deck, ifGrpThenID, belongsToGrp, deckID),
          )
        ],
      );
    },
  );
}
