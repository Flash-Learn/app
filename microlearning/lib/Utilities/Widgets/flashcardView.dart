import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCardView extends StatefulWidget {
  final Color color;
  final int currentIndex;
  final double currentPage;
  final String flashCardID;
  final bool editAccess;

  FlashCardView({
    this.color,
    this.currentIndex,
    this.currentPage,
    this.flashCardID,
    this.editAccess = true,
  });

  @override
  _FlashCardViewState createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<FlashCardView> {
  List<String> playListNames = <String>[];
  List<dynamic> userDecks = [];
  String uid;
  final CollectionReference deckReference = Firestore.instance.collection("decks");
  final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");

  var _tapPosition;
  int side = 1;
  bool isPic = false;
  String term = "";
  String definition = "";
  String display;

  void getUId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    display = term;
    side = 1;
    getUId();
  }

  @override
  Widget build(BuildContext context) {
    double relativePosition = widget.currentIndex - widget.currentPage;
    if ((widget.currentIndex - widget.currentPage).abs() >= 0.9) {}

    return StreamBuilder(
        stream: Firestore.instance
            .collection("flashcards")
            .document(widget.flashCardID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          term = snapshot.data["term"];
          definition = snapshot.data["definition"];
          isPic = (snapshot.data["isimage"] == 'true');

          bool userRemembers = true;

          dynamic tmp = snapshot.data['userRemembers'];
          if(tmp == null || tmp == false)
            userRemembers=false;
          else{
            userRemembers=true;
          }


          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            child: Padding(
              key: ValueKey<int>(side),
              // padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
              padding: const EdgeInsets.fromLTRB(8, 35, 8, 35),
              child: Container(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(1, 2, 0)
                    ..scale((1 - relativePosition.abs()).clamp(0.4, 0.6) + 0.4)
                    ..rotateY(relativePosition),
                  alignment: relativePosition >= 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Stack(children: <Widget>[
                    FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      front: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: MyColorScheme.flashcardColor(), width: 3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Spacer(),
                                    Text(
                                      term,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    widget.editAccess ? Row(
                                      children: <Widget>[
                                        RawMaterialButton(
                                          onPressed: () async{
                                            Firestore.instance
                                                .collection('flashcards')
                                                .document(widget.flashCardID)
                                                .updateData({
                                                  'userRemembers': false,
                                                });
                                            SnackBar snackBar = SnackBar(
                                              content: Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  'This card has been marked not-remembered.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: MyColorScheme.cinco()),
                                                ),
                                              ),
                                              backgroundColor: MyColorScheme.uno(),
                                              action: SnackBarAction(
                                                label: 'Undo',
                                                onPressed: (){
                                                  Firestore.instance
                                                  .collection('flashcards')
                                                  .document(widget.flashCardID)
                                                  .updateData({
                                                  'userRemembers': true,
                                                });
                                                },
                                              ),
                                            );
                                            Scaffold.of(context).showSnackBar(snackBar);
                                            await Future.delayed(Duration(seconds: 2));
                                          },
                                          elevation: 2.0,
                                          fillColor: Colors.redAccent[700],
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 35.0,
                                          ),
                                          padding: EdgeInsets.all(15.0),
                                          shape: CircleBorder(),
                                        ),
                                        Spacer(),
                                        RawMaterialButton(
                                          onPressed: () async{
                                            print(widget.flashCardID);
                                            Firestore.instance
                                                .collection('flashcards')
                                                .document(widget.flashCardID)
                                                .updateData({
                                              'userRemembers': true,
                                            });
                                            SnackBar snackBar = SnackBar(
                                              content: Padding(
                                                padding: const EdgeInsets.only(top:8.0),
                                                child: Text(
                                                  'This card has been marked remembered.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: MyColorScheme.cinco()),
                                                ),
                                              ),
                                              backgroundColor: MyColorScheme.uno(),
                                              action: SnackBarAction(
                                                label: 'Undo',
                                                onPressed: (){
                                                  Firestore.instance
                                                  .collection('flashcards')
                                                  .document(widget.flashCardID)
                                                  .updateData({
                                                    'userRemembers': false,
                                                });
                                                },
                                              ),
                                            );
                                            Scaffold.of(context).showSnackBar(snackBar);
                                            await Future.delayed(Duration(seconds: 2));
                                          },
                                          elevation: 2.0,
                                          fillColor: Colors.greenAccent[400],
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 35.0,
                                          ),
                                          padding: EdgeInsets.all(15.0),
                                          shape: CircleBorder(),
                                        )
                                      ],
                                    ) : 
                                    SizedBox(),
                                  ]
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTapDown: (details) {
                                  _tapPosition = details.globalPosition;
                                },
                                onTap: () async {
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
                                          value: "add to playlist",
                                          child: GestureDetector(
                                              onTap: () async {
                                                Navigator.pop(
                                                    context, "add to playlist");
                                                await _showbottomsheet(context);
                                              },
                                              child: Text("Add to playlists")),
                                        ),
                                      ]);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 20, 0),
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: MyColorScheme.accent(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      back: Stack(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: MyColorScheme.flashcardColor(),
                              border: Border.all(
                                  color: MyColorScheme.flashcardColor(), width: 3),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: isPic
                                  ? CachedNetworkImage(
                                      imageUrl: definition,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
//                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                  : Text(
                                      definition,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal),
                                    ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTapDown: (details) {
                                _tapPosition = details.globalPosition;
                              },
                              onTap: () async {
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
                                        value: "add to playlist",
                                        child: GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(
                                                  context, "add to playlist");
                                              await _showbottomsheet(
                                                  context); // function that makes the bottom sheet
                                            },
                                            child: Text("Add to playlists")),
                                      ),
                                    ]);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 20, 0),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: MyColorScheme.uno(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          );
        });
  }

  createAlertDialog(BuildContext ctxt) {
    String playlistname;
    return showDialog(
        context: ctxt,
        builder: (ctxt) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: MediaQuery.of(ctxt).size.height * 0.3,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    onChanged: (newplaylist) {
                      playlistname = newplaylist;
                    },
                    decoration: InputDecoration(
                      hintText: 'New PlayList',
                    ),
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
                        child: Text('Done'),
                        onPressed: () async {
                          Navigator.pop(ctxt);
                          setState(() async {
                            Deck newDeck = await createNewBlankDeck(uid, deckName: playlistname);
                          });

                          _showbottomsheet(context);
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

  List<Widget> _buildlist(BuildContext context) {
    int i = 0;
    String k;
    return userDecks.map<Widget>((dynamic deckID) {
      i++;
      k = '$i';
      return StreamBuilder(
        stream: Firestore.instance.collection('decks').document(deckID).snapshots(),
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return Text("loading");
          }

          Deck deck = Deck(deckName: snapshot.data["deckName"],
                            deckID: deckID);

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              color: MyColorScheme.accentLight(),
              child: ListTile(
                trailing: Icon(Icons.playlist_add),
                contentPadding: EdgeInsets.all(10),
                onTap: () async {
                  Navigator.pop(context);
                  dynamic flashRef = await flashcardReference.add({
                    'term': term,
                    'definition': definition,
                    'isimage': isPic ? 'true' : 'false',
                  });

                  await deckReference.document(deckID).updateData({
                    'flashcardList': FieldValue.arrayUnion([flashRef.documentID]),
                  });
                },
                title: Text(deck.deckName),
              ),
            ),
          );
        }
      );
    }).toList();
  }

  Widget bottomData(BuildContext context){
    List<Widget> children = _buildlist(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
//                Navigator.pop(context);
                createAlertDialog(context);
              },
            )
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showbottomsheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return StreamBuilder(
            stream: Firestore.instance.collection('user_data').document(uid).snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData)
                return Text("loading");
              userDecks = snapshot.data["decks"];
              return bottomData(context);
            },
          );
        });
  }
}
