import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/Decks/edit_flashcard.dart';
import 'flip_card.dart'; // created local copy of flip_card library
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

class FlashCardView extends StatefulWidget {
  final Color color;
  final int currentIndex;
  final double currentPage;
  final String flashCardID;
  final bool editAccess;
  final Function onMemorizeCallback;
  final Deck deck;
  final bool isDeckforGroup;
  final bool isTestMode;

  FlashCardView({
    this.color,
    this.currentIndex,
    this.currentPage,
    this.flashCardID,
    this.editAccess = true,
    this.onMemorizeCallback,
    this.deck,
    this.isDeckforGroup = false,
    this.isTestMode = true,
  });

  @override
  _FlashCardViewState createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<FlashCardView> {
  List<String> playListNames = <String>[];
  List<dynamic> userDecks = [];
  String uid;
  final CollectionReference deckReference =
      Firestore.instance.collection("decks");
  final CollectionReference flashcardReference =
      Firestore.instance.collection("flashcards");

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

  Future<void> clickNotMemorized() async {
    Firestore.instance
        .collection('flashcards')
        .document(widget.flashCardID)
        .updateData({
      'userRemembers': false,
    });
    SnackBar snackBar = SnackBar(
      duration: Duration(milliseconds: 900),
      content: Text(
        'This card has been marked not-remembered.',
        textAlign: TextAlign.center,
        style: TextStyle(color: MyColorScheme.accent()),
      ),
      backgroundColor: MyColorScheme.uno(),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          Firestore.instance
              .collection('flashcards')
              .document(widget.flashCardID)
              .updateData({
            'userRemembers': true,
          });
        },
      ),
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> clickMemorized() async {
    print(widget.flashCardID);
    widget.onMemorizeCallback(widget.currentIndex);
    await Firestore.instance
        .collection('flashcards')
        .document(widget.flashCardID)
        .updateData({
      'userRemembers': true,
    });
    SnackBar snackBar = SnackBar(
      duration: Duration(milliseconds: 900),
      content: Text(
        'This card has been marked remembered.',
        textAlign: TextAlign.center,
        style: TextStyle(color: MyColorScheme.accent()),
      ),
      backgroundColor: MyColorScheme.uno(),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          await Firestore.instance
              .collection('flashcards')
              .document(widget.flashCardID)
              .updateData({
            'userRemembers': false,
          });
        },
      ),
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
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
          if (!snapshot.hasData) return Center(child: Loading(size: 50));
          term = snapshot.data["term"];
          definition = snapshot.data["definition"];
          isPic = (snapshot.data["isimage"] == 'true');

          bool userRemembers = true;

          dynamic tmp = snapshot.data['userRemembers'];
          if (tmp == null || tmp == false) {
            userRemembers = false;
          } else {
            userRemembers = true;
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            child: Padding(
              key: ValueKey<int>(side),
              // padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
              padding: widget.isTestMode ? EdgeInsets.fromLTRB(8, 35, 8, 35) : EdgeInsets.fromLTRB(8, 0, 8, 35),
              child: Container(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(1, 2, 0)
                    ..scale((1 - relativePosition.abs()).clamp(0.4, 0.6) + 0.4)
                    ..rotateY(relativePosition * 1.2),
                  alignment: relativePosition >= 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Stack(children: <Widget>[
                    GestureDetector(
                      onTapDown: (details) {
                        _tapPosition = details.globalPosition;
                      },
                      onLongPress: () async {
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject();
                        await showMenu(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          context: context,
                          // found way to show delete button on the location of long press
                          // not sure how it works
                          position: RelativeRect.fromRect(
                              _tapPosition &
                                  Size(40, 40), // smaller rect, the touch area
                              Offset.zero &
                                  overlay.size // Bigger rect, the entire screen
                              ),
                          items: getPopupItems(context),
                        );
                      },
                      child: widget.isTestMode ?
                      FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
//                                  color: userRemembers ? Color.fromRGBO(149, 242, 145, 1) : Colors.red,
                                  color: Colors.white,
                                  border: Border.all(
//                                      color: MyColorScheme.flashcardColor(),
                                        color: userRemembers ? Color.fromRGBO(166, 250, 165, 1) : Color.fromRGBO(250, 165, 165, 1),
                                      width: 7),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: SingleChildScrollView(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            term,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
//                                              color: userRemembers ? Color.fromRGBO(149, 242, 145, 1) : Colors.red,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                            widget.editAccess & widget.isTestMode
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          RawMaterialButton(
                                            onPressed: () async {
                                              await clickNotMemorized();
                                            },
                                            elevation: 2.0,
                                            fillColor:
                                                Colors.redAccent[700],
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 35.0,
                                            ),
                                            padding:
                                                EdgeInsets.all(15.0),
                                            shape: CircleBorder(),
                                          ),
                                          RawMaterialButton(
                                            onPressed: () async {
                                              await clickMemorized();
                                            },
                                            elevation: 2.0,
                                            fillColor:
                                            Colors.greenAccent[400],
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 35.0,
                                            ),
                                            padding:
                                            EdgeInsets.all(15.0),
                                            shape: CircleBorder(),
                                          ),
                                        ],
                                      ),
                                  ),
                                ],
                              )
                              : SizedBox(),
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
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
                                      items: getPopupItems(context),
                                    );
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
                                    color: MyColorScheme.flashcardColor(),
                                    width: 3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      isPic
                                          ? ClipRect(
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.5,
                                                child: PhotoView(
                                                  minScale: PhotoViewComputedScale
                                                      .contained,
                                                  imageProvider:
                                                      NetworkImage(definition),
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                          color:
                                                              Colors.transparent),
                                                  maxScale: PhotoViewComputedScale
                                                          .covered *
                                                      2.0,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          ImageChunkEvent
                                                              loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return Container();
                                                    }
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes
                                                              : null),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          // ? Image.network(definition,
                                          //     loadingBuilder:
                                          //         (BuildContext context,
                                          //             Widget child,
                                          //             ImageChunkEvent
                                          //                 loadingProgress) {
                                          //     if (loadingProgress == null)
                                          //       return child;
                                          //     return Center(
                                          //       child: CircularProgressIndicator(
                                          //         value: loadingProgress
                                          //                     .expectedTotalBytes !=
                                          //                 null
                                          //             ? loadingProgress
                                          //                     .cumulativeBytesLoaded /
                                          //                 loadingProgress
                                          //                     .expectedTotalBytes
                                          //             : null,
                                          //       ),
                                          //     );
                                          //   })
                                          : Text(
                                              definition,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                    Container(height: 50,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: (widget.editAccess & widget.isTestMode)
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      RawMaterialButton(
                                        onPressed: () async {
                                          await clickNotMemorized();
                                        },
                                        elevation: 2.0,
                                        fillColor:
                                            Colors.redAccent[700],
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 35.0,
                                        ),
                                        padding: EdgeInsets.all(15.0),
                                        shape: CircleBorder(),
                                      ),
                                      RawMaterialButton(
                                        onPressed: () async {
                                          await clickMemorized();
                                        },
                                        elevation: 2.0,
                                        fillColor:
                                            Colors.greenAccent[400],
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 35.0,
                                        ),
                                        padding: EdgeInsets.all(15.0),
                                        shape: CircleBorder(),
                                      )
                                    ],
                                  )
                                : SizedBox(),
                            ),
                          ],
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
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
                                    items: getPopupItems(context),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 20, 0),
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: MyColorScheme.accent(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ]),
                      ):getLearnMode(),
                    ),
                  ]),
                ),
              ),
            ),
          );
        });
  }
   getLearnMode(){
     return LayoutBuilder(
       builder: (BuildContext context, BoxConstraints constraints) {
//         print(constraints.maxHeight);
         double minHeight = constraints.maxHeight;
         return SingleChildScrollView(
           child: Column(
             children: <Widget>[
               SizedBox(
                 height: 20,
               ),
               LayoutBuilder(

                   builder: (BuildContext context, BoxConstraints constraints) {
//                     print(constraints.maxHeight);
                     return ConstrainedBox(
                       constraints: BoxConstraints(
                         minHeight: minHeight-20,
                         minWidth: constraints.maxWidth,
                       ),
                       child: Container(
//         height: MediaQuery.of(context).size.height,
                         decoration: BoxDecoration(
                             color: Colors.white,
                             border: Border.all(
                                 color: MyColorScheme.flashcardColor(),
                                 width: 3),
                             borderRadius: BorderRadius.circular(20)),
                         child: Column(
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Padding(
                               padding: const EdgeInsets.fromLTRB(
                                   10, 30, 15, 10),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text(
                                     "TERM",
                                     style: TextStyle(
                                       color: Color.fromRGBO(27, 116, 210, 1),
                                       fontSize: 10,
                                       letterSpacing: 3,
                                       fontWeight: FontWeight.w900,
                                     ),
                                     textAlign: TextAlign.left,

                                   ),
                                   SizedBox(
                                     height: 5,
                                   ),
                                   Text(
                                     term,
                                     style: TextStyle(
                                       fontFamily: 'Roboto',
                                       color: Colors.black,
                                       fontSize: 20,
                                       letterSpacing: 1,
                                       fontWeight: FontWeight.w900,
                                     ),
                                     textAlign: TextAlign.left,
                                   ),
                                 ],
                               ),
                             ),
//              Container(padding: EdgeInsets.symmetric(horizontal: 10),child: Divider(color: MyColorScheme.accent(), thickness: 3,)),
                             Padding(
                               padding: const EdgeInsets.fromLTRB(
                                   10, 10, 15, 10),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text(
                                     "DEFINITION",
                                     style: TextStyle(
                                       color: Color.fromRGBO(27, 116, 210, 1),
                                       fontSize: 10,
                                       letterSpacing: 3,
                                       fontWeight: FontWeight.w900,
                                     ),
                                     textAlign: TextAlign.left,

                                   ),
                                   SizedBox(
                                     height: 5,
                                   ),
                                   Container(
//               height: MediaQuery.of(context).size.height * 0.4,
                                     child: !isPic ?
                                     Text(
                                         definition,
                                         style: TextStyle(
                                           fontFamily: 'Roboto',
                                           fontSize: 16,
                                           color: Colors.black,
                                           fontWeight: FontWeight.w400,
                                         ),
                                         textAlign: TextAlign.left
                                     )
                                         :
                                     ClipRect(
                                       child: Container(
                                         height: MediaQuery
                                             .of(context)
                                             .size
                                             .height *
                                             0.5,
                                         child: PhotoView(
                                           minScale: PhotoViewComputedScale
                                               .contained,
                                           imageProvider:
                                           NetworkImage(definition),
                                           backgroundDecoration:
                                           BoxDecoration(
                                               color:
                                               Colors.transparent),
                                           maxScale: PhotoViewComputedScale
                                               .covered *
                                               2.0,
                                           loadingBuilder:
                                               (BuildContext context,
                                               ImageChunkEvent
                                               loadingProgress) {
                                             if (loadingProgress == null) {
                                               return Container();
                                             }
                                             return Center(
                                               child: CircularProgressIndicator(
                                                   value: loadingProgress
                                                       .expectedTotalBytes !=
                                                       null
                                                       ? loadingProgress
                                                       .cumulativeBytesLoaded /
                                                       loadingProgress
                                                           .expectedTotalBytes
                                                       : null),
                                             );
                                           },
                                         ),
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     );
                   }


               ),
             ],
           ),
         );
       }
     );
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
                            Deck newDeck = await createNewBlankDeck(uid,
                                deckName: playlistname);
                            print(newDeck);
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
      print(k);
      return StreamBuilder(
          stream: Firestore.instance
              .collection('decks')
              .document(deckID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("loading");
            }

            Deck deck =
                Deck(deckName: snapshot.data["deckName"], deckID: deckID);

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
                      'flashcardList':
                          FieldValue.arrayUnion([flashRef.documentID]),
                    });
                  },
                  title: Text(deck.deckName),
                ),
              ),
            );
          });
    }).toList();
  }

  Widget bottomData(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            stream: Firestore.instance
                .collection('user_data')
                .document(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Loading..."),
                    ],
                  ),
                );
              userDecks = snapshot.data["decks"];
              return bottomData(context);
            },
          );
        });
  }

  getPopupItems(context) {
    List<PopupMenuItem> children = <PopupMenuItem>[];
    children.add(
      PopupMenuItem(
        value: "add to playlist",
        child: GestureDetector(
            onTap: () async {
              Navigator.pop(context, "add to playlist");
              await _showbottomsheet(
                  context); // function that makes the bottom sheet
            },
            child: Text("Add to your Decks")),
      ),
    );
    if (widget.editAccess | widget.isDeckforGroup) {
      children.add(
        PopupMenuItem(
          value: "edit deck",
          child: GestureDetector(
              onTap: () async {
                Navigator.pop(context, "edit deck");

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return EditFlashCard(
                    deck: widget.deck,
                  );
                }));
              },
              child: Text("Edit Deck")),
        ),
      );
    }
    return children;
  }
}
