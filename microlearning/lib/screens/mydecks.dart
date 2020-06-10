import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/deckInfoCard.dart';
import 'package:microlearning/screens/accountsettings.dart';
import 'package:microlearning/screens/editdeck.dart';
import 'package:microlearning/screens/viewDeck.dart';
import 'package:microlearning/helperFunctions/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';

class MyDecks extends StatefulWidget {
  // TODO: "provide" User class object using provider
//  final String userID = "nYpP671cwaWw5sL04gx9GrXDU6i1";


  // TODO: make method to get list of deck ID of user
  bool isdemo;
  MyDecks({Key key, this.isdemo = false}) : super(key: key);

  @override
  _MyDecksState createState() => _MyDecksState(isdemo: isdemo);
}

class _MyDecksState extends State<MyDecks> {
  String uid;
  bool isdemo;

  _MyDecksState({this.isdemo = false});
  static final GlobalKey<_MyDecksState> _keyNewDeck = GlobalKey<_MyDecksState>();
  static final GlobalKey<_MyDecksState> _keySearch = GlobalKey<_MyDecksState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = ['Click on this button to make a new deck', 'Click here to search for decks'];
  int _index = 0;

  spotlight(Key key){
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
              style:
                ThemeData.light().textTheme.caption.copyWith(color: Colors.white, fontSize: 35),
                textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            SizedBox(height: 20,),
            Material(
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _enabled = false;
                      isdemo = false;
                    });
                  },
                  child: Text(
                    'SKIP demo!', style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  _ontap(){
    _index++;
    if(_index == 1){
      spotlight(_keySearch);
    }else{
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if(isdemo == true){
      print('haha');
      Future.delayed(Duration(seconds: 2)).then((value) {
        spotlight(_keyNewDeck);
      });
    }
  }

  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
    return deckInfoCard(deckID);
  }

  @override
  Widget build(BuildContext context) {
//    if(userID==null)
//      return Container();
    return Spotlight(
      enabled: _enabled,
      radius: _radius,
      description: _description,
      center: _center,
      onTap: () => _ontap(),
      animation: true,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          key: _keyNewDeck,
          backgroundColor: Colors.black,
          label: Text('Create Deck', style: TextStyle(fontSize: 10),),
           icon: Icon(Icons.add),
          onPressed: () async{
            Deck newDeck = Deck(
              deckName: "",
              tagsList: [],
              isPublic: true,
            );
            
            DocumentReference deckRef = await Firestore.instance.collection("decks").add({
              "deckName": "",
              "tagsList": [],
              "flashcardList": [],
              "isPublic": true,
              "deckNameLowerCase": ""
            });

            newDeck.deckID = deckRef.documentID;

            await Firestore.instance.collection("decks").document(newDeck.deckID).updateData({
              "deckID": newDeck.deckID,
            });

            await Firestore.instance.collection("user_data").document(uid).updateData({
              "decks": FieldValue.arrayUnion([newDeck.deckID]),
            });

            Navigator.of(context).push(MaterialPageRoute(builder: (context){return EditDecks(deck: newDeck, isdemo: isdemo);}));
          },
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.black,
            centerTitle: true,
            title: Text('My Decks'),
            actions: <Widget>[
              IconButton(
                key: _keySearch,
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
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
                color: Colors.white,
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
            if(!snapshot.hasData)
              return Text("loading");
            print("user id is ${snapshot.data.getString('uid')}");
            final String userID = snapshot.data.getString('uid');
            uid = userID;
            return StreamBuilder(
                stream: Firestore.instance.collection('user_data').document(userID).snapshots(),
                builder: (context, snapshot){
                  print(userID);
                  if(!snapshot.hasData)
                    return Text("loading");
                  if(snapshot.data==null)
                    return Container();
                  final List<dynamic> userDeckIDs = snapshot.data["decks"];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ListView.builder(
                      itemCount: userDeckIDs.length,
                      itemBuilder: (BuildContext ctxt, int index) => InkWell(
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
                    ),
                  );

                }
            );
          }
        ),




      ),
    );
  }
}
