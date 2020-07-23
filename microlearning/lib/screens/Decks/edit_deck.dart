import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/Widgets/getListTags.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/screens/Decks/edit_flashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class EditDecks extends StatefulWidget {
  final Deck deck;
  final bool isdemo;
  final bool creating;
  final bool isDeckforGroup;
  final String ifGroupThenGrpID;
  EditDecks(
      {Key key,
      @required this.deck,
      this.isdemo = false,
      this.creating: false,
      this.isDeckforGroup = false,
      this.ifGroupThenGrpID: ''})
      : super(key: key);
  @override
  _EditDecksState createState() => _EditDecksState(deck: deck, isdemo: isdemo);
}

class _EditDecksState extends State<EditDecks> {
  final Deck deck;
  final _formkey = GlobalKey<FormState>();

  String error = '';
  bool isdemo;
  bool _disableTouch = false;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  text[_index],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColorScheme.uno()),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Material(
              color: MyColorScheme.accent(),
              borderRadius: BorderRadius.circular(10),
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
                    style: TextStyle(fontSize: 18, color: MyColorScheme.uno()),
                  ),
                ),
              ),
            ),
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
      Future.delayed(Duration(seconds: 1)).then((value) {
        spotlight(_keyDeckName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Spotlight(
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
                if (_formkey.currentState.validate()) {
                  setState(() {
                    _disableTouch = true;
                  });
                  await Firestore.instance
                      .collection('decks')
                      .document(deck.deckID)
                      .updateData({
                    "deckName": deck.deckName,
                    "tagsList": deck.tagsList,
                    "isPublic": deck.isPublic,
                  });

                  Navigator.push((context),
                      MaterialPageRoute(builder: (context) {
                    // TODO: save the changes made by the user in the deckInfo
                    // the changes made are stored in variable 'deck' which this page recieved when this page was made, so passing this variable only to the next page of editing the flashcards.
                    return EditFlashCard(
                      deck: deck,
                      isdemo: isdemo,
                      isDeckforGroup: widget.isDeckforGroup,
                      ifGroupThenGrpID: widget.ifGroupThenGrpID,
                    );
                  }));
                  setState(() {
                    _disableTouch = false;
                  });
                }
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
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          _disableTouch = true;
                        });
                        !widget.isDeckforGroup
                            ? await deleteDeck(deck.deckID)
                            : await deleteDeckFromGroup(
                                deck.deckID, widget.ifGroupThenGrpID);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return widget.isDeckforGroup
                              ? Group(groupID: widget.ifGroupThenGrpID)
                              : MyDecks();
                        }));
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return widget.isDeckforGroup
                              ? Group(groupID: widget.ifGroupThenGrpID)
                              : MyDecks();
                        }));
                      },
                    ),
              backgroundColor: MyColorScheme.accent(),
              title: Text(
                widget.creating ? 'Create Deck' : 'Edit Deck',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
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
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formkey,
                      child: TextFormField(
                        onChanged: (val) {
                          deck.deckName = val;
                        },
                        validator: (val) =>
                            val.isEmpty ? 'Deck Name cannot be empty' : null,
                        initialValue: deck.deckName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        decoration: inputTextDecorations('Deck Name'),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (!widget.isDeckforGroup) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                              value: deck.isPublic,
                              onChanged: (bool value) {
                                setState(() {
                                  deck.isPublic = value;
                                  print(deck.isPublic);
                                });
                              }),
                          Text(
                            'Make deck public',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ],
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.bookmark,
                          color: MyColorScheme.accent(),
                          size: 25,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Tags :',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.left,
                          key: _keyTags,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Text("Check2"),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: Container(
                        child: ListofTags(deck: deck),
                      ),
                    ),
                    // Text("Check 1"),
                    SizedBox(
                      height: 20,
                    ),
                    // Text("Check"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
