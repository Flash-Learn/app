import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/Utilities/functions/saveDeck.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'deckInfoCard.dart';

class DeckReorderList extends StatefulWidget {
  const DeckReorderList({
    Key key,
    this.belongsToGroup = false,
    this.ifGrpThenID = '',
    this.uid,
    @required this.userDeckIDs,
  }) : super(key: key);

  final bool belongsToGroup;
  final List userDeckIDs;
  final String ifGrpThenID;
  final String uid;

  @override
  _DeckReorderListState createState() => _DeckReorderListState(userDeckIDs);
}

class _DeckReorderListState extends State<DeckReorderList> {
  List<dynamic> userGroups = [];
  _DeckReorderListState(this.userDeckIDs);
  var _tapPosition;
  List<dynamic> userDeckIDs;
  bool _disableTouch = false;
  ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _disableTouch,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ReorderableListView(
          scrollController: _controller,
          scrollDirection: Axis.vertical,
          children: getDecksAsList(context, widget.userDeckIDs),
          onReorder: _onReorder,
        ),
      ),
    );
  }

  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
    return deckInfoCard(deckID, widget.ifGrpThenID, widget.belongsToGroup);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final String item = userDeckIDs.removeAt(oldIndex);
        userDeckIDs.insert(newIndex, item);
      },
    );

    // Update changes in database
    if (!widget.belongsToGroup)
      reorderDeckIDsForUser(userDeckIDs);
    else {
      // TODO: reorder decks for group
    }
  }

  getDecksAsList(BuildContext context, List<dynamic> userDeckIDs) {
    int i = 0;
    String k;
    return userDeckIDs.map<Widget>((dynamic deckId) {
      i++;
      k = '$i';
      return Container(
        key: ValueKey(k),
        height: MediaQuery.of(context).size.height * 0.23,
        child: deckInfoCard(deckId, widget.ifGrpThenID, widget.belongsToGroup),
      );
      // return Container(
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.all(Radius.circular(20)),
      //   ),
      //   height: 130,
      //   key: ValueKey(k),
      //   child: Stack(children: <Widget>[
      //     GestureDetector(
      //         onTapDown: (details) {
      //           _tapPosition = details.globalPosition;
      //         },
      //         onTap: () {
      //           print(deckId);
                // Navigator.push(
                //     context,
                //     ScaleRoute(
                //       page: ViewDeck(
                //         deckID: deckId,
                //         ifGroupThenGrpID: widget.ifGrpThenID,
                //         isDeckforGroup: widget.belongsToGroup,
                //       ),
                //     ));
      //         },
      //         child: buildDeckInfo(
      //           context,
      //           deckId,
      //         )),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: <Widget>[
      //         GestureDetector(
      //           onTapDown: (details) {
      //             _tapPosition = details.globalPosition;
      //           },
      //           onTap: () async {
      //             final RenderBox overlay =
      //                 Overlay.of(context).context.findRenderObject();
      //             await showMenu(
      //               shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.all(Radius.circular(5))),
      //               context: context,
      //               // found way to show delete button on the location of long press
      //               // not sure how it works
      //               position: RelativeRect.fromRect(
      //                   _tapPosition &
      //                       Size(40, 40), // smaller rect, the touch area
      //                   Offset.zero &
      //                       overlay.size // Bigger rect, the entire screen
      //                   ),
      //               items: [
      //                 PopupMenuItem(
      //                   value: "edit button",
      //                   child: GestureDetector(
      //                     onTap: () async {
      //                       Navigator.pop(context, "edit button");
      //                       setState(() {
      //                         _disableTouch = true;
      //                       });
      //                       Navigator.push(context,
      //                           MaterialPageRoute(builder: (context) {
      //                         Deck deck;
      //                         return StreamBuilder(
      //                           stream: Firestore.instance
      //                               .collection("decks")
      //                               .document(deckId)
      //                               .snapshots(),
      //                           builder: (context, snapshot) {
      //                             if (!snapshot.hasData)
      //                               return Scaffold(
      //                                 backgroundColor: Colors.blue[200],
      //                               );
      //                             deck = Deck(
      //                               deckName: snapshot.data["deckName"],
      //                               tagsList: snapshot.data["tagsList"],
      //                               isPublic: snapshot.data["isPublic"],
      //                             );
      //                             deck.deckID = deckId;
      //                             deck.flashCardList =
      //                                 snapshot.data["flashcardList"];
      //                             print('${widget.belongsToGroup} lolelmao');
      //                             return EditDecks(
      //                               deck: deck,
      //                               isDeckforGroup: widget.belongsToGroup,
      //                               ifGroupThenGrpID: widget.ifGrpThenID,
      //                             );
      //                           },
      //                         );
      //                       }));
      //                       setState(() {
      //                         _disableTouch = false;
      //                       });
      //                     },
      //                     child: Card(
      //                       elevation: 0,
      //                       child: Row(
      //                         children: <Widget>[
      //                           Icon(
      //                             Icons.edit,
      //                             color: MyColorScheme.accent(),
      //                           ),
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           Text(
      //                             "Edit Deck",
      //                             textAlign: TextAlign.center,
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 PopupMenuItem(
      //                   value: "add to group",
      //                   child: GestureDetector(
      //                     onTap: () {
      //                       Navigator.pop(context, "add to group");
      //                       _showBottomSheet(deckId);
      //                     },
      //                     child: Card(
      //                       elevation: 0,
      //                       child: Row(
      //                         children: <Widget>[
      //                           Icon(
      //                             Icons.library_books,
      //                             color: MyColorScheme.accent(),
      //                           ),
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           Text(
      //                             "Add to Group",
      //                             textAlign: TextAlign.center,
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 PopupMenuItem(
      //                   value: "delete button",
      //                   child: GestureDetector(
      //                     onTap: () async {
      //                       Navigator.pop(context, "delete button");
      //                       await createAlertDialog(
      //                         context,
      //                         deckId,
      //                         userDeckIDs,
      //                         widget.belongsToGroup,
      //                         widget.ifGrpThenID
      //                       );
      //                     },
      //                     child: Card(
      //                       elevation: 0,
      //                       child: Row(
      //                         children: <Widget>[
      //                           Icon(
      //                             Icons.delete,
      //                             color: MyColorScheme.accent(),
      //                           ),
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           Text(
      //                             "Delete",
      //                             textAlign: TextAlign.center,
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //               elevation: 8.0,
      //             );
      //           },
      //           child: Padding(
      //             padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
      //             child: Icon(
      //               Icons.more_horiz,
      //               color: MyColorScheme.accent(),
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //   ]),
      // );
    }).toList();
  }

  _buildGroupList(String deckId) {
    int i = 0;
    String k;
    return userGroups.map<Widget>((dynamic data) {
      i++;
      k = '$i';
      print(k);
      return StreamBuilder(
          stream: Firestore.instance
              .collection('groups')
              .document(data)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("loading");
            }

            String grpName = snapshot.data["name"];
            String grpDescription = snapshot.data["description"];

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<dynamic>(
                  stream: Firestore.instance
                      .collection("decks")
                      .document(deckId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return Card(
                      color: MyColorScheme.accentLight(),
                      child: ListTile(
                        trailing: Icon(Icons.playlist_add),
                        contentPadding: EdgeInsets.all(10),
                        onTap: () async {
                          // dynamic flashRef = await flashcardReference.add({
                          //   'term': term,
                          //   'definition': definition,
                          //   'isimage': isPic ? 'true' : 'false',
                          // });
                          Deck deck = Deck(
                            deckName: snapshot.data["deckName"],
                            tagsList: snapshot.data["tagsList"],
                            isPublic: snapshot.data["isPublic"],
                            flashCardList: snapshot.data["flashcardList"],
                          );
                          saveDecktoGroup(context, deck, deckId, data);
                          Navigator.of(context).pop();
                        },
                        title: Text(
                          grpName,
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        ),
                        subtitle: Text(
                          grpDescription,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }),
            );
          });
    }).toList();
  }

  bottomData(String deckId) {
    List<Widget> children = _buildGroupList(deckId);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10),
          height: MediaQuery.of(context).size.height * 0.56,
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

  _showBottomSheet(String deckID) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        enableDrag: true,
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
            stream: Firestore.instance
                .collection('user_data')
                .document(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Loading(size: 20));
              }
              print('hah ${widget.uid}');
              userGroups = snapshot.data["groups"];

              return bottomData(deckID);
            },
          );
        });
  }
  createAlertDialog(
      BuildContext context, String deckid, List<dynamic> userDeckIDs, bool belongsTogrp, String ifGrpthenID) 
    {
      bool isLoading = false;
      return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return AbsorbPointer(
          absorbing: _disableTouch,
          child: Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Do you want to delete this deck?',
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
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: !isLoading ? Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ) : Loading(size: 10, color: MyColorScheme.accent(),),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                                _disableTouch = true;
                                userDeckIDs.remove(deckid);
                              });
                              !belongsTogrp
                                  ? await deleteDeck(deckid)
                                  : await deleteDeckFromGroup(
                                      deckid, ifGrpthenID);
                              setState(() {
                                _disableTouch = false;
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {});
  }
}