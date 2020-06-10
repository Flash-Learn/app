import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/getlisttags.dart';
import 'package:microlearning/screens/editflashcards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';

class EditDecks extends StatefulWidget {
  final Deck deck;
  bool isdemo;
  EditDecks({Key key, @required this.deck, this.isdemo = false}) : super(key: key);
  @override
  _EditDecksState createState() => _EditDecksState(deck: deck, isdemo: isdemo);
}

class _EditDecksState extends State<EditDecks> {
  final Deck deck;
  bool isdemo;
  _EditDecksState({@required this.deck, this.isdemo = false});
  static final GlobalKey<_EditDecksState> _keyDeckName = GlobalKey<_EditDecksState>();
  static final GlobalKey<_EditDecksState> _keyTags = GlobalKey<_EditDecksState>();
  static final GlobalKey<_EditDecksState> _keyEditFlash = GlobalKey<_EditDecksState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = ['Add a deck name for you deck', 'Add tags for your deck', 'Create Flash Cards for your deck'];
  int _index = 0;

  spotlight(Key key){
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = Offset(target.center.dx, target.center.dy);
      _radius = Spotlight.calcRadius(target);
      _description = Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text[_index],
              style:
                ThemeData.light().textTheme.caption.copyWith(color: Colors.white, fontSize: 35),
                textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            SizedBox(height: 20,),
            Material(
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _enabled = false;
                      isdemo = false;
                    });
                  },
                  child: Text(
                    'SKIP demo!', style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  _ontap(){
    _index++;
    if(_index == 1){
      spotlight(_keyTags);
    } else if(_index == 2){
      spotlight(_keyEditFlash);
    }
    else{
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    if(isdemo == true){
      print('haha');
      Future.delayed(Duration(seconds: 2)).then((value) {
        spotlight(_keyDeckName);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Spotlight(
      enabled: _enabled,
      radius: _radius,
      description: _description,
      center: _center,
      onTap: () => _ontap(),
      animation: true,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          key: _keyEditFlash,
          onPressed: () async {
            await Firestore.instance.collection('decks').document(deck.deckID).updateData({
              "deckName": deck.deckName,
              "tagsList": deck.tagsList,
              "deckNameLowerCase": deck.deckName.toLowerCase(),
              "searchKey": deck.deckName[0].toLowerCase()
            });

            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
              // TODO: save the changes made by the user in the deckInfo
              // the changes made are stored in variable 'deck' which this page recieved when this page was made, so passing this variable only to the next page of editing the flashcards.
              return EditFlashCard(deck: deck, isdemo: isdemo);
            }));
          },
          backgroundColor: Colors.black,
          icon: Icon(
            Icons.keyboard_arrow_right,
          ),
          label: Text('Add or Edit Flashcards'),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
//        actions: <Widget>[
//          Padding(
//            padding: EdgeInsets.only(right: 20.0),
//            child: GestureDetector(
//              onTap: () {
//                //TODO: submit the changes made by the user on the local storage as well as database
//              },
//              child: Icon(
//                Icons.done,
//                size: 26.0,
//              ),
//            )
//          ),
//        ],
          backgroundColor: Colors.black, 
          title: Text('Edit Deck'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Deck Name :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,key: _keyDeckName,),
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
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Tags :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.left,key: _keyTags,),
                  ],
                ),
                SizedBox(height: 10,),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: Container(
//                  maxHei: 300,
                    child: ListofTags(deck: deck),
                  ),
                ),
                SizedBox(
                  height:20,
                ),
                RaisedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String uid = prefs.getString('uid');
                    await Firestore.instance.collection("deck").document(deck.deckID).delete();
                    await Firestore.instance.collection("user_data").document(uid).updateData({
                      "decks": FieldValue.arrayRemove([deck.deckID]),
                    });

                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) => MyDecks(),
                    ), (Route<dynamic> route) => false);

                  },
                  child: Text("Delete Deck"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}