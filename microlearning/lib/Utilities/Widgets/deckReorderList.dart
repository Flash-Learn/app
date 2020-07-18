import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'deckInfoCard.dart';

class DeckReorderList extends StatefulWidget {
  const DeckReorderList({
    Key key,
    this.belongsToGroup = false,
    this.ifGrpThenID = '',
    @required this.userDeckIDs,
  }) : super(key: key);

  final bool belongsToGroup;
  final List userDeckIDs;
  final String ifGrpThenID;

  @override
  _DeckReorderListState createState() => _DeckReorderListState(userDeckIDs);
}

class _DeckReorderListState extends State<DeckReorderList> {
  _DeckReorderListState(this.userDeckIDs);
  var _tapPosition;
  List<dynamic> userDeckIDs;
  bool _disableTouch = false;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _disableTouch,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ReorderableListView(
          scrollDirection: Axis.vertical,
          children: getDecksAsList(context, widget.userDeckIDs),
          onReorder: _onReorder,
        ),
      ),
    );
  }

  Widget buildDeckInfo(BuildContext ctxt, String deckID) {
    return deckInfoCard(deckID);
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        height: 130,
        key: ValueKey(k),
        child: Stack(children: <Widget>[
          GestureDetector(
              onTapDown: (details) {
                _tapPosition = details.globalPosition;
              },
              onTap: () {
                print(deckId);
                Navigator.push(
                    context,
                    ScaleRoute(
                      page: ViewDeck(
                        deckID: deckId,
                        ifGroupThenGrpID: widget.ifGrpThenID,
                        isDeckforGroup: widget.belongsToGroup,
                      ),
                    ));
              },
              child: buildDeckInfo(
                context,
                deckId,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTapDown: (details) {
                  _tapPosition = details.globalPosition;
                },
                onTap: () async {
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject();
                  await showMenu(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              Deck deck;
                              return StreamBuilder(
                                stream: Firestore.instance
                                    .collection("decks")
                                    .document(deckId)
                                    .snapshots(),
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
                                  deck.deckID = deckId;
                                  deck.flashCardList =
                                      snapshot.data["flashcardList"];
                                  print('${widget.belongsToGroup} lolelmao');
                                  return EditDecks(
                                    deck: deck,
                                    isDeckforGroup: widget.belongsToGroup,
                                    ifGroupThenGrpID: widget.ifGrpThenID,
                                  );
                                },
                              );
                            }));
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
                                Text(
                                  "Edit Deck",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete button",
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context, "delete button");
                            setState(() {
                              _disableTouch = true;
                            });
                            createAlertDialog(
                              context,
                              deckId,
                              userDeckIDs,
                            );
                            setState(() {
                              _disableTouch = false;
                            });
                          },
                          child: Card(
                            elevation: 0,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.delete,
                                  color: MyColorScheme.accent(),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Delete",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    elevation: 8.0,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 5, 0),
                  child: Icon(
                    Icons.more_horiz,
                    color: MyColorScheme.accent(),
                  ),
                ),
              )
            ],
          ),
        ]),
      );
    }).toList();
  }

  createAlertDialog(
      BuildContext ctxt, String deckid, List<dynamic> userDeckIDs) {
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
                          setState(() {
                            _disableTouch = false;
                            userDeckIDs.remove(deckid);
                          });
                          !widget.belongsToGroup
                              ? await deleteDeck(deckid)
                              : await deleteDeckFromGroup(
                                  deckid, widget.ifGrpThenID);
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
