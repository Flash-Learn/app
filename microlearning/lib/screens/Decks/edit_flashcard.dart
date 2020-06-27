import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/functions/updateFlashcardList.dart';
import 'package:microlearning/Utilities/Widgets/getFlashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class EditFlashCard extends StatefulWidget {
  final Deck deck;
  final bool isdemo;
  EditFlashCard({Key key, @required this.deck, this.isdemo = false})
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

  GlobalKey<_EditFlashCardState> _keyFlashcard =
      GlobalKey<_EditFlashCardState>();
  GlobalKey<_EditFlashCardState> _keySave = GlobalKey<_EditFlashCardState>();
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColorScheme.uno()),
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
              height: MediaQuery.of(context).size.height*0.2,
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
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.extended(
            key: _keySave,
            backgroundColor: MyColorScheme.accent(),
            icon: _disableTouch ? null : Icon(Icons.check),
            label: _disableTouch
                ? Loading(size: 20)
                : Text(
                    'Save Deck',
                    style: TextStyle(fontSize: 15),
                  ), // Show loading icon when clicked
            onPressed: () async {
              setState(() {
                _disableTouch = true;
              });
//              flashCardData.insert(1, ['', '']); // hotfix to remove all the blank cards
              await updateFlashcardList(deck, flashCardData);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ViewDeck(
                      deckID: newDeck.deckID,
                      backAvailable: false,
                      isdemo: isdemo,
                    ),
                  ),
                  (Route<dynamic> route) => false);
            },
          ),
          appBar: AppBar(
            elevation: 2,
            backgroundColor: MyColorScheme.uno(),
            title: Text(
              'Edit Deck',
              style: TextStyle(
                  color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: MyColorScheme.accent(),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              key: _keyFlashcard,
              children: <Widget>[
                StreamBuilder<Object>(
                    stream: getCardfromDataBase,
                    // TODO: add the stream here for the getting the 2d array of the things
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (flashCardData.length - 1 ==
                          newDeck.flashCardList.length + 1) {
                        // flashCardData.add(['','']);
                        return Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: GetFlashCardEdit(
                            deck: deck,
                            flashCardData: flashCardData,
                          ),
                        );
                      } else {
                        return Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
