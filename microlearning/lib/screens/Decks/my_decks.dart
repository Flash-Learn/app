import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/screens/authentication/init_info.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/services/firebase_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class MyDecks extends StatefulWidget {
  bool isdemo;
  MyDecks({Key key, this.isdemo = false}) : super(key: key);

  @override
  _MyDecksState createState() => _MyDecksState(isdemo: isdemo);
}

class _MyDecksState extends State<MyDecks> {
  String uid;

  // if state is updated with _disableTouch, touch is disabled/enabled depending on it's value
  bool isdemo, _disableTouch = false;
  var _tapPosition;
  _MyDecksState({this.isdemo = false});
  GlobalKey<_MyDecksState> _keyNewDeck = GlobalKey<_MyDecksState>();
  GlobalKey<_MyDecksState> _keySearch = GlobalKey<_MyDecksState>();
  GlobalKey<_MyDecksState> _keyGroups = GlobalKey<_MyDecksState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Click on this button \n to make a new deck',
    'Click here to search for decks',
  ];
  List<dynamic> userDeckIDs;
  int _index = 0;
  int selectedIndex = 0;
  PushNotificationService notificationService = PushNotificationService();

  spotlight(Key key) {
    _index++;
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = Offset(target.center.dx, target.center.dy);
      _radius = Spotlight.calcRadius(target);
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
                  text[_index - 1],
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
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      );
    });
  }

  _ontap() {
    if (_index == 1) {
      spotlight(_keySearch);
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    notificationService.initialise();
  }

  @override
  Widget build(BuildContext context) {
    if (isdemo == true && _index == 0) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        spotlight(_keyNewDeck);
      });
    }
    // Widget for app demo
    return Spotlight(
      enabled: _enabled,
      radius: _radius,
      description: _description,
      center: _center,
      onTap: () => _ontap(),
      animation: true,

      // Widget to block taps during loading
      child: AbsorbPointer(
        absorbing: _disableTouch,
        child: Container(
          // only for gradient
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromRGBO(84, 205, 255, 1),
                Color.fromRGBO(84, 205, 255, 1),
                Color.fromRGBO(27, 116, 210, 1)
              ])),
          child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              bottomNavigationBar: customBottomNav(),
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                  elevation: 2,
                  // backgroundColor: MyColorScheme.uno(),
                  backgroundColor: Color.fromRGBO(196, 208, 223, 0),
                  centerTitle: true,
                  title: Text(
                    'My Decks',
                    style: TextStyle(
                        color: MyColorScheme.uno(),
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    IconButton(
                      key: _keySearch,
                      icon: Icon(
                        Icons.search,
                        color: MyColorScheme.uno(),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/search',
                        );
                      },
                    ),
                  ],
                  leading: IconButton(
                    icon: Icon(
                      Icons.account_circle,
                      color: MyColorScheme.uno(),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AccountSettings();
                          },
                        ),
                      );
                    },
                  )),
              body: GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx < 0) {
                    Navigator.pushNamed(
                      context,
                      '/search',
                    );
                  }
                },
                child: FutureBuilder(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Text("loading");
                      print("user id is ${snapshot.data.getString('uid')}");
                      final String userID = snapshot.data.getString('uid');
                      uid = userID;
                      return StreamBuilder(
                          stream: Firestore.instance
                              .collection('user_data')
                              .document(userID)
                              .snapshots(),
                          builder: (context, snapshot) {
                            print(userID);
                            if (!snapshot.hasData) return Text("loading");
                            if (snapshot.data == null) return Container();
                            try {
                              userDeckIDs = snapshot.data["decks"];
                            } catch (e) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return GetUserInfo();
                              }));
                            }
                            return DeckReorderList(
                              userDeckIDs: userDeckIDs,
                            );
                          });
                    }),
              )),
        ),
      ),
    );
  }

  customBottomNav() {
    return Container(
      height: 80,
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            splashColor: MyColorScheme.accent(),
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.library_books,
                  color: Colors.amber,
                ),
                SizedBox(
                  height: 5,
                ),
                Text('MyDecks',
                    style: TextStyle(
                      color: Colors.amber,
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _disableTouch = true;
              });
              // newDeck is a bank new deck, which is being passed into the edit deck screen
              Deck newDeck = await createNewBlankDeck(uid);
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return EditDecks(deck: newDeck, isdemo: isdemo, creating: true);
              }));
              setState(() {
                _disableTouch = false;
              });
            },
            child: Material(
              elevation: 2,
              color: Color.fromRGBO(50, 217, 157, 1),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _disableTouch
                    ? Loading(
                        size: 20,
                      )
                    : Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            color: MyColorScheme.uno(),
                          ),
                          Text(
                            'Create Deck',
                            style: TextStyle(color: MyColorScheme.uno()),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: MyColorScheme.accent(),
            onTap: () {
              Navigator.popAndPushNamed(
                context,
                '/groups',
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.group,
                  color: MyColorScheme.uno(),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'MyGroups',
                  style: TextStyle(color: MyColorScheme.uno()),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

//class ReorderList extends StatefulWidget {
//  const ReorderList({
//    Key key,
//    @required this.userDeckIDs,
//  }) : super(key: key);
//
//  final List userDeckIDs;
//
//  @override
//  _ReorderListState createState() => _ReorderListState(userDeckIDs);
//}
//
//class _ReorderListState extends State<ReorderList> {
//  _ReorderListState(this.userDeckIDs);
//  var _tapPosition;
//  List<dynamic> userDeckIDs;
//  bool _disableTouch = false;
//  @override
//  Widget build(BuildContext context) {
//    return AbsorbPointer(
//      absorbing: _disableTouch,
//      child: Padding(
//        padding: const EdgeInsets.symmetric(horizontal: 40),
//        child: ReorderableListView(
//          scrollDirection: Axis.vertical,
//          children: getDecksAsList(context, widget.userDeckIDs),
//          onReorder: _onReorder,
//        ),
//      ),
//    );
//  }
//
//  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
//    return deckInfoCard(deckID);
//  }
//
//  void _onReorder(int oldIndex, int newIndex) {
//    setState(
//      () {
//        if (newIndex > oldIndex) {
//          newIndex -= 1;
//        }
//        final String item = userDeckIDs.removeAt(oldIndex);
//        userDeckIDs.insert(newIndex, item);
//      },
//    );
//
//    // Update changes in database
//    reorderDeckIDsForUser(userDeckIDs);
//  }
//
//  getDecksAsList(BuildContext context, List<dynamic> userDeckIDs) {
//    int i = 0;
//    String k;
//    return userDeckIDs.map<Widget>((dynamic deckId) {
//      i++;
//      k = '$i';
//      return Container(
//        height: 130,
//        key: ValueKey(k),
//        child: Stack(children: <Widget>[
//          GestureDetector(
//              onTapDown: (details) {
//                _tapPosition = details.globalPosition;
//              },
//              onTap: () {
//                print(deckId);
//                Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => ViewDeck(
//                        deckID: deckId,
//                      ),
//                    ));
//              },
//              child: buildDeckInfo(context, deckId)),
//          Row(
//            mainAxisAlignment: MainAxisAlignment.end,
//            children: <Widget>[
//              GestureDetector(
//                onTapDown: (details) {
//                  _tapPosition = details.globalPosition;
//                },
//                onTap: () async {
//                  final RenderBox overlay =
//                      Overlay.of(context).context.findRenderObject();
//                  await showMenu(
//                    context: context,
//                    // found way to show delete button on the location of long press
//                    // not sure how it works
//                    position: RelativeRect.fromRect(
//                        _tapPosition &
//                            Size(40, 40), // smaller rect, the touch area
//                        Offset.zero &
//                            overlay.size // Bigger rect, the entire screen
//                        ),
//                    items: [
//                      PopupMenuItem(
//                        value: "edit button",
//                        child: GestureDetector(
//                          onTap: () async {
//                            Navigator.pop(context, "edit button");
//                            setState(() {
//                              _disableTouch = true;
//                            });
//                            Navigator.pushReplacement(context,
//                                MaterialPageRoute(builder: (context) {
//                              Deck deck;
//                              return StreamBuilder(
//                                stream: Firestore.instance
//                                    .collection("decks")
//                                    .document(deckId)
//                                    .snapshots(),
//                                builder: (context, snapshot) {
//                                  if (!snapshot.hasData)
//                                    return Scaffold(
//                                      backgroundColor: Colors.blue[200],
//                                    );
//                                  deck = Deck(
//                                    deckName: snapshot.data["deckName"],
//                                    tagsList: snapshot.data["tagsList"],
//                                    isPublic: snapshot.data["isPublic"],
//                                  );
//                                  deck.deckID = deckId;
//                                  deck.flashCardList =
//                                      snapshot.data["flashcardList"];
//                                  print(snapshot);
//                                  return EditDecks(
//                                    deck: deck,
//                                  );
//                                },
//                              );
//                            }));
//                            setState(() {
//                              _disableTouch = false;
//                            });
//                          },
//                          child: Card(
//                            elevation: 0,
//                            child: Row(
//                              children: <Widget>[
//                                Icon(
//                                  Icons.edit,
//                                  color: MyColorScheme.accent(),
//                                ),
//                                SizedBox(
//                                  width: 10,
//                                ),
//                                Text(
//                                  "Edit Deck",
//                                  textAlign: TextAlign.center,
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                      PopupMenuItem(
//                        value: "delete button",
//                        child: GestureDetector(
//                          onTap: () async {
//                            Navigator.pop(context, "delete button");
//                            setState(() {
//                              _disableTouch = true;
//                            });
//                            createAlertDialog(context, deckId, userDeckIDs);
//                            setState(() {
//                              _disableTouch = false;
//                            });
//                          },
//                          child: Card(
//                            elevation: 0,
//                            child: Row(
//                              children: <Widget>[
//                                Icon(
//                                  Icons.delete,
//                                  color: MyColorScheme.accent(),
//                                ),
//                                SizedBox(
//                                  width: 10,
//                                ),
//                                Text(
//                                  "Delete",
//                                  textAlign: TextAlign.center,
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                    elevation: 8.0,
//                  );
//                },
//                child: Padding(
//                  padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
//                  child: Icon(
//                    Icons.more_horiz,
//                    color: MyColorScheme.accent(),
//                  ),
//                ),
//              )
//            ],
//          ),
//        ]),
//      );
//    }).toList();
//  }
//
//  createAlertDialog(
//      BuildContext ctxt, String deckid, List<dynamic> userDeckIDs) {
//    return showDialog(
//        context: ctxt,
//        builder: (ctxt) {
//          return Dialog(
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(20.0)),
//            child: Container(
//              height: MediaQuery.of(ctxt).size.height * 0.2,
//              padding: EdgeInsets.all(15),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  Text(
//                    'Do you want to delete the deck?',
//                  ),
//                  SizedBox(
//                    height: 20,
//                  ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      FlatButton(
//                        child: Text('Cancel'),
//                        onPressed: () {
//                          Navigator.pop(ctxt);
//                        },
//                      ),
//                      FlatButton(
//                        child: Text(
//                          'Delete',
//                          style: TextStyle(color: Colors.red),
//                        ),
//                        onPressed: () async {
//                          setState(() {
//                            _disableTouch = false;
//                            userDeckIDs.remove(deckid);
//                          });
//                          await deleteDeck(deckid);
//                          Navigator.pop(ctxt);
//                        },
//                      )
//                    ],
//                  )
//                ],
//              ),
//            ),
//          );
//        });
//  }
//}
