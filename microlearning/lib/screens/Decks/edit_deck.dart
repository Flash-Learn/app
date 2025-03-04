import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/Widgets/getListTags.dart';
import 'package:microlearning/screens/Decks/edit_flashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class EditDecks extends StatefulWidget {
  final Deck deck;
  bool isdemo;
  bool creating;
  EditDecks(
      {Key key, @required this.deck, this.isdemo = false, this.creating: false})
      : super(key: key);
  @override
  _EditDecksState createState() => _EditDecksState(deck: deck, isdemo: isdemo);
}

class _EditDecksState extends State<EditDecks> {
  bool _disableTouch = false;
  final Deck deck;
  bool isdemo;
  _EditDecksState({@required this.deck, this.isdemo = false});

  GlobalKey<_EditDecksState> _keyDeckName = GlobalKey<_EditDecksState>();
  GlobalKey<_EditDecksState> _keyTags = GlobalKey<_EditDecksState>();
  GlobalKey<_EditDecksState> _keyEditFlash = GlobalKey<_EditDecksState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Add a deck name for you deck',
    'Add tags for your deck',
    'Create Flash Cards for your deck'
  ];
  int _index = 0;

  spotlight(Key key) {
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
              style: ThemeData.light()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 35),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            Material(
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _enabled = false;
                      isdemo = false;
                    });
                  },
                  child: Text(
                    'SKIP demo!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  _ontap() {
    _index++;
    if (_index == 1) {
      spotlight(_keyTags);
    } else if (_index == 2) {
      spotlight(_keyEditFlash);
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (isdemo == true) {
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
      child: AbsorbPointer(
        absorbing: _disableTouch,
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            key: _keyEditFlash,
            onPressed: () async {
              setState(() {
                _disableTouch = true;
              });
              await Firestore.instance
                  .collection('decks')
                  .document(deck.deckID)
                  .updateData({
                "deckName": deck.deckName,
                "tagsList": deck.tagsList,
                "deckNameLowerCase": deck.deckName.toLowerCase(),
                "searchKey": deck.deckName[0].toLowerCase()
              });

              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                // TODO: save the changes made by the user in the deckInfo
                // the changes made are stored in variable 'deck' which this page recieved when this page was made, so passing this variable only to the next page of editing the flashcards.
                return EditFlashCard(deck: deck, isdemo: isdemo);
              }));
            },
            backgroundColor: MyColorScheme.accent(),
            icon: Icon(
              Icons.keyboard_arrow_right,
            ),
            label: Text('Add or Edit Flashcards'),
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: widget.creating
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: MyColorScheme.accent(),
                    ),
                    onPressed: () async {
                      setState(() {
                        _disableTouch = true;
                      });
                      deleteDeck(deck.deckID);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return MyDecks();
                      }));
                    },
                  )
                : null,
            backgroundColor: MyColorScheme.uno(),
            title: Text(
              'Edit Deck',
              style: TextStyle(
                  color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),
            ),
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
                      Icon(
                        Icons.filter_none,
                        color: MyColorScheme.accent(),
                        size: 30,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Deck Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.left,
                        key: _keyDeckName,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (val) {
                      deck.deckName = val;
                    },
                    initialValue: deck.deckName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Deck Name',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.all(20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.bookmark,
                        color: MyColorScheme.accent(),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Tags :',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.left,
                        key: _keyTags,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                    height: 20,
                  ),
//                RaisedButton(
//                  onPressed: () async {
//                    SharedPreferences prefs = await SharedPreferences.getInstance();
//                    String uid = prefs.getString('uid');
//                    await Firestore.instance.collection("deck").document(deck.deckID).delete();
//                    await Firestore.instance.collection("user_data").document(uid).updateData({
//                      "decks": FieldValue.arrayRemove([deck.deckID]),
//                    });
//
//                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
//                      builder: (context) => MyDecks(),
//                    ), (Route<dynamic> route) => false);
//
//                  },
//                  child: Text("Delete Deck"),
//                )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
