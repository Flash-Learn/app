import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/flashcard.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/functions/updateFlashcardList.dart';
import 'package:microlearning/Utilities/Widgets/getFlashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:flutter/scheduler.dart';

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
  List<FlashCard> flashCardData;
  Deck deck;

  _EditFlashCardState({@required this.deck, this.isdemo});

  Deck newDeck;

  static final GlobalKey<_EditFlashCardState> _keyFlashcard =
      GlobalKey<_EditFlashCardState>();
  static final GlobalKey<_EditFlashCardState> _keySave =
      GlobalKey<_EditFlashCardState>();
  static final GlobalKey<_EditFlashCardState> _keyAddOne =
      GlobalKey<_EditFlashCardState>();
  static final GlobalKey<_EditFlashCardState> _keyAddTwo =
      GlobalKey<_EditFlashCardState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Make changes to you \n flash card here.',
    'Click here to save your deck',
    'Click here to make \n Two-Sided Card',
    'Click here to make \n One-Sided Card'
  ];
  int _index = 0;

  bool _disableTouch = false;
  bool isLoading = true;

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
    } else if (_index == 2) {
      spotlight(_keyAddTwo);
    } else if (_index == 3) {
      spotlight(_keyAddOne);
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
    flashCardData = <FlashCard>[];

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
          flashCardData.add(FlashCard(
                  term: ref.data["term"],
                  definition: ref.data["definition"],
                  isTermPhoto: ref.data["isTermPhoto"],
                  isDefinitionPhoto: ref.data["isDefinitionPhoto"],
                  isOneSided: ref.data["isOneSided"])
              // FlashCard(term: ref.data["term"],defintion: ref.data["definition"], ref.data['isimage'])
              );
        });
      }
      flashCardData.add(FlashCard(
          term: '',
          definition: '',
          isTermPhoto: false,
          isDefinitionPhoto: false,
          isOneSided: false));
      setState(() {
        isLoading = false;
      });
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
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.white,
                appBar: AppBar(
                  elevation: 2,
                  backgroundColor: MyColorScheme.accent(),
                  title: Text(
                    'Edit Deck',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
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
                      child: _disableTouch
                          ? Container(
                              child: Center(
                              child: Loading(
                                size: 20,
                              ),
                            ))
                          : Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white,
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
                      if (isLoading == false) ...[
                        // flashCardData.add(['','']);
                        Container(
                          padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
                          child: Column(
                            children: <Widget>[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // Container(
                                    //   // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    // ),
                                    Material(
                                      key: _keyAddTwo,
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.red[300],
                                      child: MaterialButton(
                                        //color: Colors.blue,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.add,
                                              color: Colors.black,
                                            ),
                                            // SizedBox(
                                            //   width: 3,
                                            // ),
                                            Text(
                                              "Two-sided Card",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            flashCardData.add(FlashCard(
                                                term: '',
                                                definition: '',
                                                isTermPhoto: false,
                                                isDefinitionPhoto: false,
                                                isOneSided: false));
                                            //TODO: generate a id for flash card....But I don't think we will need this
                                          });
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    // Text("hel;lop"),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.red[300],
                                      child: MaterialButton(
                                        key: _keyAddOne,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.add,
                                              color: Colors.black,
                                            ),
                                            //   SizedBox(
                                            //     width: 3,
                                            //   ),
                                            Text(
                                              "One-sided Card",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            // fieldCount++;
                                            try {
                                              setState(() {
                                                flashCardData.add(FlashCard(
                                                    term: '',
                                                    definition: '',
                                                    isTermPhoto: false,
                                                    isDefinitionPhoto: false,
                                                    isOneSided: true));
                                              });
                                            } catch (e) {
                                              print('here is the error');
                                              print(e);
                                            }
                                            //TODO: generate a id for flash card....But I don't think we will need this
                                          });
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GetFlashCardEdit(
                                scrollController: _scrollController,
                                deck: deck,
                                flashCardData: flashCardData,
                                scaffoldKey: _scaffoldKey,
                              ),
                            ],
                          ),
                        )
                      ] else ...[
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: SizedBox(
                              child: Center(child: CircularProgressIndicator()),
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
          );
        });
  }
}
