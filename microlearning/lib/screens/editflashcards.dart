import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/updateFlashcardList.dart';
import 'package:microlearning/helperWidgets/getflashcards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/viewDeck.dart';

class EditFlashCard extends StatefulWidget {
  final Deck deck;
  EditFlashCard({Key key, @required this.deck}): super(key: key);
  @override
  _EditFlashCardState createState() => _EditFlashCardState(deck: deck);
}

class _EditFlashCardState extends State<EditFlashCard> {
//  List<List<String>> flashCardDatatemp = [<String>[]];
  static List<List<String>> flashCardData;
  Deck deck;
  _EditFlashCardState({@required this.deck});
  static Deck newDeck;

  @override
  initState(){
    super.initState();
    newDeck = deck;
    flashCardData = [<String>[]];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
//      floatingActionButtonLocation: FloatingActionButtonLocation.rightFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: Icon(Icons.check),
        onPressed: (){
          // TODO: save the changes made by the user in the flash cards of the deck.
          // popping the current screen and taking the user back to the deck card info page.
          updateFlashcardList(deck, flashCardData);

          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Deck'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: (){
                //TODO: submit the changes made by the user on the local storage as well as database and return to mydecks.
              },
              child: Icon(
                Icons.done,
                size: 26,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder<Object>(
            stream: getCardfromDataBase, // TODO: add the stream here for the getting the 2d array of the things
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.hasData){  
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  height: 600,
                  child: GetFlashCardEdit(deck: deck, flashCardData: flashCardData),
                );
              }
              else{
                return Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                );
              }
            }
          ),
        ],
      ),
    );
  }

  Stream<dynamic> getCardfromDataBase = (() async* {
//    await Future<void>.delayed(Duration(seconds: 1));
//    yield 1;
    // add the function to get the flashcards from database and save it in flashCardData, while retriving data from 
    // the database make sure to initialise flashCardData as List<List<String>> flashCardData = [<String>[]], 
    // this will make flashCardData[0] as null but it is the only way it is working and I made my code work according to this.
    final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");

    for(var i=0; i<newDeck.flashCardList.length; i++){
      flashcardReference.document(newDeck.flashCardList[i]).get().then((ref){
        flashCardData.add([ref.data["term"], ref.data["definition"]]);
      });
    }

    yield 1;
  })();
}