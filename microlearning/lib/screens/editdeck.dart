import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/getlisttags.dart';
import 'package:microlearning/screens/editflashcards.dart';

class EditDecks extends StatefulWidget {
  final Deck deck;
  EditDecks({Key key, @required this.deck}) : super(key: key);
  @override
  _EditDecksState createState() => _EditDecksState(deck: deck);
}

class _EditDecksState extends State<EditDecks> {
  final Deck deck;
  _EditDecksState({@required this.deck});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            // TODO: save the changes made by the user in the deckInfo
            // the changes made are stored in variable 'deck' which this page recieved when this page was made, so passing this variable only to the next page of editing the flashcards.
            return EditFlashCard(deck: deck);
          }));
        },
        child: Icon(
          Icons.keyboard_arrow_right,
        ),
      ),
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                //TODO: submit the changes made by the user on the local storage as well as database
              },
              child: Icon(
                Icons.done,
                size: 26.0,
              ),
            )
          ),
        ],
        backgroundColor: Colors.red, 
        title: Text('Edit Deck'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Deck Name:', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
              ],
            ),
            SizedBox(height: 10,),
            TextFormField(
              onChanged: (val){
                deck.deckName = val;
              },
              initialValue: deck.deckName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              decoration: InputDecoration(
                hintText: "Deck Name",
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.all(12.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
              ],
            ),
            SizedBox(height: 10,),
            Container(
              height: 300,
              child: ListofTags(deck: deck),
            ),
          ],
        ),
      ),
    );
  }
}