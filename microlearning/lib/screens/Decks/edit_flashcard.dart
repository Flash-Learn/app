import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/functions/updateFlashcardList.dart';
import 'package:microlearning/Utilities/Widgets/getFlashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class EditFlashCard extends StatefulWidget {
  final Deck deck;
  final bool isdemo;
  final bool isDeckforGroup;
  final String ifGroupThenGrpID;
  EditFlashCard(
      {Key key,
      @required this.deck,
      this.isdemo = false,
      this.isDeckforGroup = false,
      this.ifGroupThenGrpID = ''})
      : super(key: key);
  @override
  _EditFlashCardState createState() =>
      _EditFlashCardState(deck: deck, isdemo: isdemo);
}

class _EditFlashCardState extends State<EditFlashCard> {
  bool isdemo;
  Stream<dynamic> getCardfromDataBase;
  List<List<String>> flashCardData;
  Deck deck;

  _EditFlashCardState({@required this.deck, this.isdemo});

  Deck newDeck;

  static final GlobalKey<_EditFlashCardState> _keyFlashcard =
      GlobalKey<_EditFlashCardState>();
  static final GlobalKey<_EditFlashCardState> _keySave =
      GlobalKey<_EditFlashCardState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Make changes to you \n flash card here',
    'Click here to save your deck'
  ];
  int _index = 0;

  bool _disableTouch = false;

  spotlight(Key key) {
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = _index == 0
          ? Offset(
              target.topCenter.dx, target.topCenter.dy + (target.height / 6))
          : Offset(target.center.dx, target.center.dy);
      _radius = _index == 0 ? 100 : Spotlight.calcRadius(target);
      _description = Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
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
            SizedBox(
              height: 100,
            ),
          ],
        ),
      );
    });
  }

  _ontap() {
    _index++;
    if (_index == 1) {
      spotlight(_keySave);
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
    if (isdemo == true) {
      print('haha');
      Future.delayed(Duration(seconds: 2)).then((value) {
        spotlight(_keyFlashcard);
      });
    }
    newDeck = deck;
    flashCardData = [<String>[]];

    getCardfromDataBase = (() async* {
      // add the function to get the flashcards from database and save it in flashCardData, while retriving data from
      // the database make sure to initialise flashCardData as List<List<String>> flashCardData = [<String>[]],
      // this will make flashCardData[0] as null but it is the only way it is working and I made my code work according to this.
      final CollectionReference flashcardReference =
          Firestore.instance.collection("flashcards");
      for (var i = 0; i < newDeck.flashCardList.length; i++) {
        print("flash card id: ${newDeck.flashCardList[i]}");
        await flashcardReference
            .document(newDeck.flashCardList[i])
            .get()
            .then((ref) {
          flashCardData.add(
              [ref.data["term"], ref.data["definition"], ref.data['isimage']]);
        });
      }
      flashCardData.add(['', '', 'false']);
      print(flashCardData.length);
      print("yield go brrr");
      yield 1;
    })();
  }

  @override
  Widget build(BuildContext context) {
    // Widget to give demo to new user
    return StreamBuilder<Object>(
        stream: getCardfromDataBase,
        builder: (context, snapshot) {
          return Spotlight(
            enabled: _enabled,
            radius: _radius,
            description: _description,
            center: _center,
            onTap: () => _ontap(),
            animation: true,
            // Widget to disable touch when loading
            child: AbsorbPointer(
              absorbing: _disableTouch,
              child: WillPopScope(
                onWillPop: () async => false,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 2,
                    backgroundColor: MyColorScheme.uno(),
                    title: Text(
                      'Edit Deck',
                      style: TextStyle(
                          color: MyColorScheme.cinco(),
                          fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: MyColorScheme.accent(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        key: _keySave,
                        onPressed: () async {
                          setState(() {
                            _disableTouch = true;
                          });
                          //              flashCardData.insert(1, ['', '']); // hotfix to remove all the blank cards
                          await updateFlashcardList(deck, flashCardData);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ViewDeck(
                                deckID: newDeck.deckID,
                                backAvailable: false,
                                isdemo: isdemo,
                                isDeckforGroup: widget.isDeckforGroup,
                                ifGroupThenGrpID: widget.ifGroupThenGrpID,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.check,
                              color: MyColorScheme.accent(),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Save',
                              style: TextStyle(
                                  color: MyColorScheme.accent(),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      key: _keyFlashcard,
                      children: <Widget>[
                        if (flashCardData.length - 1 ==
                            newDeck.flashCardList.length + 1) ...[
                          //   // flashCardData.add(['','']);
                          //   Container(
                          //     padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          //     child: SingleChildScrollView(
                          //       child: GetFlashCardEdit(
                          //         deck: deck,
                          //         flashCardData: flashCardData,
                          //       ),
                          //     ),
                          //   )
                          // ] else ...[
                          Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: SizedBox(
                                child:
                                    Center(child: CircularProgressIndicator()),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
