import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/getflashcards.dart';

class EditFlashCard extends StatefulWidget {
  final Deck deck;
  EditFlashCard({Key key, @required this.deck}): super(key: key);
  @override
  _EditFlashCardState createState() => _EditFlashCardState(deck: deck);
}

class _EditFlashCardState extends State<EditFlashCard> {
  Deck deck;
  _EditFlashCardState({@required this.deck});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: Icon(Icons.keyboard_arrow_left),
        onPressed: (){
          // TODO: save the changes made by the user in the flash cards of the deck.
          // popping the current screen and taking the user back to the deck card info page.
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
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        height: 600,
        child: GetFlashCardEdit(deck: deck),
      ),
    );
  }
}