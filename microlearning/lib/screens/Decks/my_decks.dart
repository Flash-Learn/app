import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/Widgets/deckInfoCard.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/screens/authentication/init_info.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/services/notification_plugin.dart';

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
  GlobalKey<_MyDecksState> _keyplaylist = GlobalKey<_MyDecksState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Click on this button \n to make a new deck',
    'Click here to search for decks',
    'Click here to browse playlists',
  ];
  int _index = 0;
  final notification = Notifications();

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
    } else if (_index == 2) {
      setState(() {
        spotlight(_keyplaylist);
      });
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    notification.initializeNotifications();
  }

  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
    return deckInfoCard(deckID);
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
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            key: _keyNewDeck,
            backgroundColor: MyColorScheme.accent(),
            label: _disableTouch
                ? Loading(size: 20)
                : Text(
                    'Create Deck',
                    style: TextStyle(fontSize: 10),
                  ), // show loading if touch is disabled, otherwise show text
            icon: _disableTouch
                ? null
                : Icon(Icons.add), // if touch is disabled remove the add Icon
            onPressed: () async {
              setState(() {
                _disableTouch = true;
              });

              // newDeck is a bank new deck, which is being passed into the edit deck screen
              Deck newDeck = await createNewBlankDeck(uid);

              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EditDecks(deck: newDeck, isdemo: isdemo, creating: true);
              }));
            },
          ),
          backgroundColor: MyColorScheme.dos(),
          appBar: AppBar(
              elevation: 2,
              backgroundColor: MyColorScheme.uno(),
              centerTitle: true,
              title: Text(
                'My Decks',
                style: TextStyle(
                    color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                IconButton(
                  color: MyColorScheme.accent(),
                  icon: Icon(Icons.notifications),
                  onPressed: () async {
                    DateTime now = DateTime.now().toUtc().add(
                          Duration(seconds: 20),
                        );
                    await notification.singleNotification(
                      now,
                      "Notification",
                      "This is a notification",
                      98123871,
                    );
                    print("haha");
                  },
                ),
                IconButton(
                  key: _keyplaylist,
                  icon: Icon(Icons.featured_play_list),
                  color: MyColorScheme.accent(),
                  onPressed: () {
                    Navigator.pushNamed(context, '/playlistmanage');
                  },
                ),
                IconButton(
                  key: _keySearch,
                  icon: Icon(
                    Icons.search,
                    color: MyColorScheme.accent(),
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
                  color: MyColorScheme.accent(),
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
          body: FutureBuilder(
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
                      List<dynamic> userDeckIDs;
                      try {
                        userDeckIDs = snapshot.data["decks"];
                      } catch (e) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return GetUserInfo();
                        }));
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ListView.builder(
                          itemCount: userDeckIDs.length,
                          itemBuilder: (BuildContext ctxt, int index) =>
                              Stack(children: <Widget>[
                            GestureDetector(
                                onTapDown: (details) {
                                  _tapPosition = details.globalPosition;
                                },
                                onLongPress: () async {
                                  final RenderBox overlay = Overlay.of(context)
                                      .context
                                      .findRenderObject();
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
                                    items: [
                                      PopupMenuItem(
                                        value: "delete button",
                                        child: GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(
                                                  context, "delete button");
                                              setState(() {
                                                _disableTouch = true;
                                              });
                                              createAlertDialog(
                                                  ctxt, userDeckIDs[index]);
                                              setState(() {
                                                _disableTouch = false;
                                              });
                                            },
                                            child: Text("Delete")),
                                      ),
                                    ],
                                    elevation: 8.0,
                                  );
                                },
                                onTap: () {
                                  print(userDeckIDs[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewDeck(
                                          deckID: userDeckIDs[index],
                                        ),
                                      ));
                                },
                                child: buildDeckInfo(ctxt, userDeckIDs[index])),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTapDown: (details) {
                                    _tapPosition = details.globalPosition;
                                  },
                                  onTap: () async {
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject();
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
                                      items: [
                                        PopupMenuItem(
                                          value: "delete button",
                                          child: GestureDetector(
                                              onTap: () async {
                                                Navigator.pop(
                                                    context, "delete button");
                                                setState(() {
                                                  _disableTouch = true;
                                                });
                                                createAlertDialog(
                                                    ctxt, userDeckIDs[index]);
                                                setState(() {
                                                  _disableTouch = false;
                                                });
                                              },
                                              child: Text("Delete")),
                                        ),
                                      ],
                                      elevation: 8.0,
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 10, 0),
                                    child: Icon(
                                      Icons.more_horiz,
                                      color: MyColorScheme.accent(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ]),
                        ),
                      );
                    });
              }),
        ),
      ),
    );
  }

  createAlertDialog(BuildContext ctxt, String deckid) {
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
                  Text(
                    'Do you want to delete the deck?',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(ctxt);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          await deleteDeck(deckid);
                          setState(() {
                            _disableTouch = false;
                          });
                          Navigator.pop(ctxt);
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
