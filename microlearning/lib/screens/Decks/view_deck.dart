import 'package:flutter/material.dart';
import 'package:microlearning/screens/Decks/edit_flashcard.dart';
import 'package:microlearning/screens/Groups/group.dart';
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
  final bool isDeckforGroup;
  final String ifGroupThenGrpID;
  ViewDeck(
      {Key key,
      @required this.deckID,
      this.editAccess = true,
      this.backAvailable = true,
      this.isdemo = false,
      this.ifGroupThenGrpID = '',
      this.isDeckforGroup = false})
      : super(key: key);
  @override
  _ViewDeckState createState() =>
      _ViewDeckState(deckID: deckID, isdemo: isdemo);
}

class _ViewDeckState extends State<ViewDeck> {
  bool showAllcards = true;
  bool isdemo;
  String deckID;
  bool isShuffled = false;
  double completedPercentage = 0;
  Deck deck;
  bool isTestMode = false;
  Key whenShuffled = UniqueKey();
  Key whenNotShuffled = UniqueKey();

  _ViewDeckState({this.deckID, this.isdemo});
  bool _disableTouch = false;
  final notification = Notifications();

  var _tapPosition;

  // error here @samay
  GlobalKey<_FlashCardSwipeViewState> _keyFlashcard =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyEdit =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyMode =
      GlobalKey<_FlashCardSwipeViewState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Click here for editing \n and more actions on deck',
    'Tap on the flash card to \n flip and view the other side',
    'Click here to switch between \n read mode and learn mode'
  ];
  int _index = 0;

  spotlight(Key key) {
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = Offset(target.center.dx, target.center.dy);
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
    } else if(_index == 2){
      spotlight(_keyMode);
    }else {
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

  void changePercentage(double percentage, double numberOfCards) {
    if (numberOfCards > 1)
      percentage = (percentage - 1 / numberOfCards) / (1 - 1 / numberOfCards);
    else
      percentage = 1;
    percentage = percentage < 0.0 ? 0.0 : percentage;
    percentage = percentage > 1.0 ? 1.0 : percentage;
    setState(() {
      completedPercentage = percentage;
    });
  }
  _showSnackbar(String text){
    final snackbar = new SnackBar(
      content: Text(text, textAlign: TextAlign.center, style: TextStyle(color: MyColorScheme.accent()),),
      backgroundColor: MyColorScheme.uno(),
      duration: Duration(seconds: 1),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream:
            Firestore.instance.collection("decks").document(deckID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Scaffold(
              backgroundColor: Colors.blue[200],
            );
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
                key: _scaffoldKey,
                appBar: AppBar(
                  // backgroundColor: MyColorScheme.uno(),
                  // backgroundColor: Color.fromRGBO(118, 174, 247, 1),
                  backgroundColor: Colors.lightBlue[200],
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: MyColorScheme.uno(),
                    onPressed: () {
                      !widget.backAvailable
                          ? Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context)  {
                                return widget.isDeckforGroup ? Group(groupID: widget.ifGroupThenGrpID,): MyDecks();}
                              ),
                              (Route<dynamic> route) => false)
                          : Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    if (widget.editAccess) ...[
                      Container(
                      key: _keyMode,
                      child: isTestMode ?
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                            icon: Icon(Icons.chrome_reader_mode),
                            onPressed: (){
                              setState(() {
                               isTestMode = !isTestMode;
                               _showSnackbar('Switched to learn mode');
                              });
                            },
                          ),
                        ) :
                        Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          icon: Icon(Icons.check_box),
                          onPressed: (){
                            WidgetsBinding.instance.addPostFrameCallback((_){
                              setState(() {
                              isTestMode = !isTestMode;
                              _showSnackbar('Switched to test mode');
                            });});
                          },
                        ),
                        )
                      ),
                      Padding(
                        key: _keyEdit,
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
                                      Size(40,
                                          40), // smaller rect, the touch area
                                  Offset.zero &
                                      overlay
                                          .size // Bigger rect, the entire screen
                                  ),
                              items: getPopUpItems(),
                              elevation: 8.0,
                            );
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: MyColorScheme.uno(),
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(Icons.file_download),
                          color: MyColorScheme.accent(),
                          onPressed: () {
                            saveDeck(context, deck, deckID);
                          },
                        ),
                      )
                    ]
                  ],
                  centerTitle: true,
                  title: Text(
                    deck.deckName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MyColorScheme.uno()),
                  ),
                ),
                body: Container(
                  key: _keyFlashcard,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color.fromRGBO(84, 205, 255, 1),
                        Color.fromRGBO(84, 205, 255, 1),
                        Color.fromRGBO(27, 116, 210, 1)
                      ])),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: FlashCardSwipeView(
                            deck: deck,
                            showAllCards: showAllcards,
                            editAccess: widget.editAccess,
                            changePercentage: changePercentage,
                            isShuffled: isShuffled,
                            key: isShuffled ? whenShuffled : whenNotShuffled,
                            ifGroupThenGrpID: widget.ifGroupThenGrpID,
                            isDeckforGroup: widget.isDeckforGroup,
                            isTestMode: isTestMode,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Text(
                                  "Progress:",
                                  style: TextStyle(
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
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
      ),
    );
  }

  Deck _getThingsOnStartup() {
    Deck deck = getDeckFromID(deckID);
    return deck;
  }

  createAlertDialog(BuildContext ctxt) {
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

  getPopUpItems() {
    List<PopupMenuItem> list = <PopupMenuItem>[
      PopupMenuItem(
        value: "edit button",
        child: GestureDetector(
            onTap: () async {
              Navigator.pop(context, "edit button");
              setState(() {
                _disableTouch = true;
              });
              if (widget.editAccess)
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return widget.isDeckforGroup ? EditDecks(isDeckforGroup: true, deck: deck, ifGroupThenGrpID: widget.ifGroupThenGrpID,) : EditDecks(deck: deck);
                }));
              else {
                print(deck.flashCardList.length);
              }
              setState(() {
                _disableTouch = false;
              });
            },
            child: Card(
              elevation: 0,
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
              ),
            )),
      ),
      PopupMenuItem(
        value: "shuffle button",
        child: GestureDetector(
            onTap: () async {
              Navigator.pop(context, "shuffle button");
              setState(() {
                _disableTouch = true;
                isShuffled = !isShuffled;
                print(isShuffled);
              });
              setState(() {
                _disableTouch = false;
              });
            },
            child: Card(
              elevation: 0,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shuffle,
                    color: MyColorScheme.accent(),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(isShuffled ? "Un-shuffle deck" : "Shuffle Deck"),
                ],
              ),
            )),
      ),
     if(!widget.isDeckforGroup)...[ PopupMenuItem(
        value: "filter button",
        child: GestureDetector(
            onTap: () async {
              Navigator.pop(context, "filter button");
              setState(() {
                showAllcards = !showAllcards;
              });
            },
            child: Card(
              elevation: 0,
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
              ),
            )),
      ),]else...[
        PopupMenuItem(
          child: GestureDetector(
            onTap: () async {
              Navigator.pop(context, "filter button");
              saveDeck(context, deck, deckID);
            },
            child: Card(
              elevation: 0,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.file_download,
                    color: MyColorScheme.accent(),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Download Deck')
                ],
              ),
            )),
        ),
      ],
      PopupMenuItem(
        value: "notification button",
        child: GestureDetector(
            onTap: () async {
              try {
                Navigator.pop(context, "notification button");
                Duration resultingDuration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(hours: 0, minutes: 10));
                // print(resultingDuration.inHours);
                // print(resultingDuration.inMinutes);
                if (resultingDuration != null) {
                  DateTime now = DateTime.now().toUtc().add(
                        Duration(
                            hours: resultingDuration.inHours,
                            minutes: resultingDuration.inMinutes),
                      );
                  await notification.singleNotification(
                    now,
                    "Reminder",
                    "Revise your deck '${deck.deckName}'",
                  );
                  print(notification.i2);
                  SnackBar snackBar = SnackBar(
                    duration: Duration(milliseconds: 1200),
                    content: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Reminder set!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: MyColorScheme.cinco()),
                      ),
                    ),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          notification.cancelNotifications();
                          // print('cancelled');
                          SnackBar snackBar = SnackBar(
                            duration: Duration(milliseconds: 1200),
                            content: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Reminder cancelled',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: MyColorScheme.cinco()),
                              ),
                            ),
                            backgroundColor: MyColorScheme.uno(),
                          );
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        }),
                    backgroundColor: MyColorScheme.uno(),
                  );
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                }
              } catch (e) {
                print(e);
              }
            },
            child: Card(
              elevation: 0,
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
              ),
            )),
      ),
    ];
    return list;
  }
}

class FlashCardSwipeView extends StatefulWidget {
  @override
  FlashCardSwipeView({
    this.deck,
    this.showAllCards,
    this.editAccess,
    this.changePercentage,
    this.isShuffled,
    this.ifGroupThenGrpID = '',
    this.isDeckforGroup = false,
    this.isTestMode = false,
    @required this.key,
  });
  final bool isShuffled;
  final Key key;
  final dynamic changePercentage;
  final Deck deck;
  final bool editAccess;
  final bool showAllCards;
  final bool isDeckforGroup;
  final String ifGroupThenGrpID;
  final bool isTestMode;

  _FlashCardSwipeViewState createState() =>
      _FlashCardSwipeViewState(deck: deck, isShuffled: isShuffled);
}

class _FlashCardSwipeViewState extends State<FlashCardSwipeView> {
  _FlashCardSwipeViewState({
    this.deck,
    this.isShuffled,
  });

  final Deck deck;
  bool isShuffled;
  PageController _pageCtrl = PageController(viewportFraction: 0.9);

  double numberOfCards = 1;
  double currentPage = 0.0;
  int currentView = 2;
  bool shuffleState = false;
  bool isTestMode = false;

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
        widget.changePercentage(
            (_pageCtrl.page + 1) / numberOfCards, numberOfCards);
        currentPage = _pageCtrl.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // if(widget.isTestMode){
    //   print('hahalmaolol');
    //   WidgetsBinding.instance.addPostFrameCallback((_){
    //     setState(() {
    //       isTestMode = true;
    //     });
    //   });
    // }
    if (widget.showAllCards) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          numberOfCards = deck.flashCardList.length.toDouble();
          //        _pageCtrl.jumpToPage(0);
          if (currentView == 2) {
            shuffleState = false;
            currentView = 1;
            _pageCtrl.jumpToPage(0);
            currentPage = _pageCtrl.page;
            widget.changePercentage(
                (_pageCtrl.page + 1) / numberOfCards, numberOfCards);
          }
        });
      });
      List<dynamic> cardsRemembered = deck.flashCardList;

      void doNothing(int index) {
        print("memorized");
      }

      if (isShuffled && !shuffleState) {
        cardsRemembered.shuffle();
        shuffleState = true;
        print("shuffling");
      } else if (!isShuffled && shuffleState) {
        cardsRemembered = deck.flashCardList;
        shuffleState = false;
        print("unshuffle");
      }
      return Container(
        child: PageView(
          controller: _pageCtrl,
          scrollDirection: Axis.horizontal,
          children:
              getCardsAsList(cardsRemembered, widget.editAccess, doNothing),
          // controller: _pageCtrl,
          // scrollDirection: Axis.horizontal,
          // itemCount: cardsRemembered.length,
          // itemBuilder: (context, int currentIndex) {
          //   return FlashCardView(
          //     color: Colors.accents[currentIndex],
          //     currentIndex: currentIndex,
          //     currentPage: currentPage,
          //     flashCardID: cardsRemembered[currentIndex],
          //     editAccess: widget.editAccess,
          //     onMemorizeCallback: doNothing,
          //   );
          // }
        ),
      );
    }

    return FutureBuilder(
        future: getNotRememberedCards(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(
                size: 50,
              ),
            );
          }

          List<dynamic> cardsNotRemembered = snapshot.data;

          void deleteAtIndex(int index) {
            cardsNotRemembered.removeAt(index);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            //
            setState(() {
              numberOfCards = cardsNotRemembered.length.toDouble();
              if (currentView == 1) {
                currentView = 2;
                shuffleState = false;
                _pageCtrl.jumpToPage(0);
                currentPage = 0;
                widget.changePercentage(
                    (_pageCtrl.page + 1) / numberOfCards, numberOfCards);
              }
            });
          });
          return Container(
            child: PageView.builder(
                controller: _pageCtrl,
                scrollDirection: Axis.horizontal,
                itemCount: cardsNotRemembered.length,
                itemBuilder: (context, int currentIndex) {
                  //  print("${_pageCtrl.page}, $currentPage, $currentIndex");
                  //  if(currentIndex >= cardsNotRemembered.length){
                  //    _pageCtrl.jumpToPage(0);
                  if (isShuffled && !shuffleState) {
                    cardsNotRemembered.shuffle();
                    shuffleState = true;
                    print("shuffling");
                  } else if (!isShuffled && shuffleState) {
                    cardsNotRemembered = snapshot.data;
                    shuffleState = false;
                    print("unshuffle");
                  }
                  try {
                    return FlashCardView(
                      color: Colors.accents[currentIndex + 1],
                      currentIndex: currentIndex,
                      currentPage: currentPage,
                      flashCardID: cardsNotRemembered[currentIndex],
                      onMemorizeCallback: deleteAtIndex,
                      deck: deck,
                    );
                  } catch (e) {
                    _pageCtrl.jumpToPage(0);
                  }
                  return Container();
                }),
          );
        });
  }

  getCardsAsList(List<dynamic> cards, bool editaccess, Function onmemocall) {
    List<Widget> children = cards.map<Widget>((dynamic data) {
      return FlashCardView(
        flashCardID: data,
        editAccess: editaccess^widget.isDeckforGroup ^ !widget.isTestMode,
        onMemorizeCallback: onmemocall,
        currentIndex: cards.indexOf(data),
        currentPage: currentPage,
        deck: deck,
      );
    }).toList();
    double relativePosition = cards.length - currentPage;
    if (editaccess == true) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 35, 8, 35),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(1, 2, 0)
              ..scale((1 - relativePosition.abs()).clamp(0.4, 0.6) + 0.4)
              ..rotateY(relativePosition * 1.2),
            alignment: relativePosition >= 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return EditFlashCard(
                    deck: deck,
                  );
                })));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: MyColorScheme.flashcardColor(), width: 3),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }
}
