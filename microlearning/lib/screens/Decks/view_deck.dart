import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/functions/getDeckFromID.dart';
import 'package:microlearning/Utilities/functions/saveDeck.dart';
import 'package:microlearning/Utilities/Widgets/flashcardView.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Models/notification_plugin.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';

class ViewDeck extends StatefulWidget {
  final bool isdemo;
  final String deckID;
  final editAccess;
  final bool backAvailable;
  ViewDeck(
      {Key key,
      @required this.deckID,
      this.editAccess = true,
      this.backAvailable = true,
      this.isdemo = false})
      : super(key: key);
  @override
  _ViewDeckState createState() =>
      _ViewDeckState(deckID: deckID, isdemo: isdemo);
}

class _ViewDeckState extends State<ViewDeck> {
  bool showAllcards = true;
  bool isdemo;
  String deckID;
  double completedPercentage = 0;
  Deck deck;
  _ViewDeckState({this.deckID, this.isdemo});
  bool _disableTouch = false;
  final notification = Notifications();

  var _tapPosition;

  // error here @samay
  GlobalKey<_FlashCardSwipeViewState> _keyFlashcard =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyEdit =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyshuffle =
      GlobalKey<_FlashCardSwipeViewState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Click here to edit the deck',
    'Tap on the flash card to \n flip and view the other side',
    'Click here to shuffle the \n deck of flashcards',
  ];
  int _index = 0;

  spotlight(Key key) {
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = _index == 1
          ? Offset(target.center.dx, target.center.dy)
          : Offset(target.center.dx, target.center.dy);
      _radius = _index == 1
          ? Spotlight.calcRadius(target) * 0.1
          : Spotlight.calcRadius(target);
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
              height: MediaQuery.of(context).size.height * 0.15,
            )
          ],
        ),
      );
    });
  }

  _ontap() async {
    _index++;
    if (_index == 1) {
      spotlight(_keyFlashcard);
    } else if (_index == 2) {
      spotlight(_keyshuffle);
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
//    deck = _getThingsOnStartup();
    super.initState();
    if (isdemo == true) {
      print('haha');
    }
    if (isdemo == true && _index == 0) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        spotlight(_keyEdit);
      });
    }
    notification.initializeNotifications();
  }

  void changePercentage(double percentage) {
    setState(() {
      completedPercentage = percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection("decks").document(deckID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text("loading...");
        deck = Deck(
          deckName: snapshot.data["deckName"],
          tagsList: snapshot.data["tagsList"],
          isPublic: snapshot.data["isPublic"],
        );
        deck.deckID = deckID;
        deck.flashCardList = snapshot.data["flashcardList"];
        return Spotlight(
            enabled: _enabled,
            radius: _radius,
            description: _description,
            center: _center,
            onTap: () => _ontap(),
            animation: true,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: MyColorScheme.uno(),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: MyColorScheme.accent(),
                  onPressed: () {
                    widget.editAccess
                        ? Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => MyDecks(),
                            ),
                            (Route<dynamic> route) => false)
                        : Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTapDown: (details) {
                        _tapPosition = details.globalPosition;
                      },
                      onTap: () async {
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject();
                        await showMenu(
                          context: context,
                          // found way to show delete button on the location of long press
                          // not sure how it works
                          position: RelativeRect.fromRect(
                              _tapPosition &
                                  Size(40, 40), // smaller rect, the touch area
                              Offset.zero &
                                  overlay.size // Bigger rect, the entire screen
                              ),
                          items: [
                            PopupMenuItem(
                              value: "edit button",
                              child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context, "edit button");
                                    setState(() {
                                      _disableTouch = true;
                                    });
                                    if (widget.editAccess)
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return EditDecks(deck: deck);
                                      }));
                                    else {
                                      print(deck.flashCardList.length);
                                      saveDeck(context, deck);
                                    }
                                    setState(() {
                                      _disableTouch = false;
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.edit,
                                        color: MyColorScheme.accent(),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Edit Deck"),
                                    ],
                                  )),
                            ),
                            PopupMenuItem(
                              value: "shuffle button",
                              child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context, "shuffle button");
                                    setState(() {
                                      _disableTouch = true;
                                      deck.flashCardList.shuffle();
                                    });
                                    setState(() {
                                      _disableTouch = false;
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.shuffle,
                                        color: MyColorScheme.accent(),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Shuffle Deck"),
                                    ],
                                  )),
                            ),
                            PopupMenuItem(
                              value: "filter button",
                              child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context, "filter button");
                                    setState(() {
                                      showAllcards = !showAllcards;
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.filter_list,
                                        color: MyColorScheme.accent(),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      showAllcards
                                          ? Text("Not memorized cards")
                                          : Text("Show all cards"),
                                    ],
                                  )),
                            ),
                            PopupMenuItem(
                              value: "notification button",
                              child: GestureDetector(
                                  onTap: () async {
                                    try{Navigator.pop(
                                        context, "notification button");
                                    Duration resultingDuration =
                                        await showDurationPicker(
                                            context: context,
                                            initialTime: Duration(
                                                hours: 0, minutes: 10));
                                    // print(resultingDuration.inHours);
                                    // print(resultingDuration.inMinutes);
                                    if(resultingDuration!=null){DateTime now = DateTime.now().toUtc().add(
                                          Duration(
                                              hours: resultingDuration.inHours,
                                              minutes:
                                                  resultingDuration.inMinutes),
                                        );
                                    await notification.singleNotification(
                                      now,
                                      "Reminder",
                                      "Revise your deck '${deck.deckName}'",
                                    );}}catch(e){
                                      print(e);
                                    }
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.notifications,
                                        color: MyColorScheme.accent(),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Remind me later')
                                    ],
                                  )),
                            ),
                          ],
                          elevation: 8.0,
                        );
                      },
                      child: Icon(
                        Icons.more_horiz,
                        color: MyColorScheme.accent(),
                      ),
                    ),
                  ),
                ],
                centerTitle: true,
                title: Text(
                  deck.deckName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MyColorScheme.cinco()),
                ),
              ),
              body: Container(
                color: Color.fromRGBO(27, 116, 240, 1),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        key: _keyFlashcard,
                        child: FlashCardSwipeView(
                          deck: deck,
                          showAllCards: showAllcards,
                          editAccess: widget.editAccess,
                          changePercentage: changePercentage,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 30,
                        ),
                        LinearPercentIndicator(
                          percent: completedPercentage,
                          backgroundColor: Colors.blueGrey[400],
                          width: MediaQuery.of(context).size.width - 60,
                          // // animation: true,
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: Colors.white,
                          lineHeight: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }

  Deck _getThingsOnStartup() {
    Deck deck = getDeckFromID(deckID);
    return deck;
  }

  createAlertDialog(
    BuildContext ctxt,
  ) {
    return showDialog(
        context: ctxt,
        builder: (ctxt) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: MediaQuery.of(ctxt).size.height * 0.2,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Done'),
                        onPressed: () {
                          Navigator.pop(ctxt);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class FlashCardSwipeView extends StatefulWidget {
  @override
  FlashCardSwipeView({
    this.deck,
    this.showAllCards,
    this.editAccess,
    this.changePercentage,
  });
  final dynamic changePercentage;
  final Deck deck;
  final bool editAccess;
  final bool showAllCards;
  _FlashCardSwipeViewState createState() =>
      _FlashCardSwipeViewState(deck: deck);
}

class _FlashCardSwipeViewState extends State<FlashCardSwipeView> {
  _FlashCardSwipeViewState({
    this.deck,
  });

  final Deck deck;
  PageController _pageCtrl = PageController(viewportFraction: 0.9);

  double numberOfCards = 1;
  double currentPage = 0.0;
  int currentView=1;

  Future<List<dynamic>> getNotRememberedCards() async {
    List<dynamic> ret = [];
    for (var cardID in deck.flashCardList) {
      var document =
          Firestore.instance.collection('flashcards').document(cardID);
      await document.get().then((document) {
        dynamic tmp = document["userRemembers"];
        if (tmp != true) ret.add(cardID);
      });
    }

    return ret;
  }

  @override
  void initState() {
    // TODO: implement initState
    // TODO: implement initState
    super.initState();
    _pageCtrl.addListener(() {
      setState(() {
        widget.changePercentage((_pageCtrl.page + 1) / numberOfCards);
        currentPage = _pageCtrl.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAllCards) {
      setState(() {
        numberOfCards = deck.flashCardList.length.toDouble();
//        _pageCtrl.jumpToPage(0);
        if(currentView==2) {
          currentView=1;
          _pageCtrl.jumpToPage(0);
          currentPage=_pageCtrl.page;
        }
      });
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromRGBO(84, 205, 255, 1),
              Color.fromRGBO(84, 205, 255, 1),
              Color.fromRGBO(27, 116, 210, 1)
            ])),
        child: PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.horizontal,
            itemCount: deck.flashCardList.length,
            itemBuilder: (context, int currentIndex) {
              return FlashCardView(
                color: Colors.accents[currentIndex],
                currentIndex: currentIndex,
                currentPage: currentPage,
                flashCardID: deck.flashCardList[currentIndex],
                editAccess: widget.editAccess,
              );
            }),
      );
    }

    return FutureBuilder(
        future: getNotRememberedCards(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return Loading(
              size: 50,
            );
          }

          List<dynamic> cardsNotRemembered = snapshot.data;

          WidgetsBinding.instance.addPostFrameCallback((_){
            // Add Your Code here.
            setState(() {
              numberOfCards = cardsNotRemembered.length.toDouble();
              if(currentView==1) {
                currentView=2;
                _pageCtrl.jumpToPage(0);
                currentPage=0;
              }
            });
          });

          return Container(
//            color: Colors.white,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(84, 205, 255, 1),
                      Color.fromRGBO(84, 205, 255, 1),
                      Color.fromRGBO(27, 116, 210, 1)
                    ])),
            child: PageView.builder(
                controller: _pageCtrl,
                scrollDirection: Axis.horizontal,
                itemCount: cardsNotRemembered.length,
                itemBuilder: (context, int currentIndex) {
//                print("${_pageCtrl.page}, $currentPage, $currentIndex");
//                if(currentIndex >= cardsNotRemembered.length){
//                  _pageCtrl.jumpToPage(0);
//                }
                  try {
                    return FlashCardView(
                      color: Colors.accents[currentIndex + 1],
                      currentIndex: currentIndex,
                      currentPage: currentPage,
                      flashCardID: cardsNotRemembered[currentIndex],
                    );
                  } catch (e) {
                    _pageCtrl.jumpToPage(0);
                  }
                  return Container();
                }),
          );
        });
  }
}
