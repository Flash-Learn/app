import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';
import 'package:microlearning/screens/Search/search.dart';
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
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => Search(),
                        ));
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
                        SlideRightRoute(page: AccountSettings()),
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
                      if (!snapshot.hasData)
                        return Center(
                          child: Loading(
                            size: 50,
                          ),
                        );
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
                            if (!snapshot.hasData)
                              return Center(
                                child: Loading(
                                  size: 50,
                                ),
                              );
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
                              uid: uid,
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
      height: 70,
      // padding: EdgeInsets.only(bottom: 20),
      color: Color.fromRGBO(57, 146, 210, 1),
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
              key: _keyNewDeck,
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
              Navigator.of(context)
                  .pushReplacement(FadeRoute(page: GroupList()));
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
