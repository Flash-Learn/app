import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Groups/edit_group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class Group extends StatefulWidget {
  final String groupID;
  final String uid;
  Group({
    this.groupID,
    this.uid,
  });

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  bool _disableTouch = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return GroupList();
        }));
      },
      child: AbsorbPointer(
        absorbing: _disableTouch,
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('groups')
                .document(widget.groupID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading(
                  size: 50,
                );
              }

              print(widget.groupID);
              GroupData group = GroupData(
                groupID: widget.groupID,
                description: snapshot.data["description"],
                name: snapshot.data["name"],
                decks: snapshot.data["decks"],
                users: snapshot.data["users"],
                admins: snapshot.data["admins"],
              );
              return Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() {
                      _disableTouch = true;
                    });
                    Deck newdeck = await addDeckToGroup(widget.groupID);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditDecks(
                        deck: newdeck,
                        creating: true,
                        isdemo: false,
                        isDeckforGroup: true,
                        ifGroupThenGrpID: widget.groupID,
                      );
                    }));
                  },
                  label: Text('Add a deck'),
                  icon: Icon(Icons.add),
                  backgroundColor: MyColorScheme.accent(),
                ),
                appBar: AppBar(
                  backgroundColor: MyColorScheme.accent(),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacement(FadeRoute(page: GroupList()));
                    },
                  ),
                  title: Text(
                    snapshot.data["name"],
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        setState(() {
                          _disableTouch = true;
                        });
                        if (group.admins != null &&
                            !group.admins.contains([group.users[0]])) {
                          await Firestore.instance
                              .collection('groups')
                              .document(group.groupID)
                              .updateData({
                            "admins": FieldValue.arrayUnion([group.users[0]]),
                          });
                        }
                        Navigator.pushReplacement(context,
                            CupertinoPageRoute(builder: (context) {
                          return EditGroup(
                            groupData: group,
                            userUid: widget.uid,
                          );
                        }));
                      },
                    ),
                    // IconButton(
                    //   // key: _keySearch,
                    //   icon: Icon(
                    //     Icons.search,
                    //     color: MyColorScheme.uno(),
                    //   ),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                body: Container(
                  color: Colors.blue[50],
                  child: DeckReorderList(
                    userDeckIDs: group.decks,
                    belongsToGroup: true,
                    ifGrpThenID: group.groupID,
                    uid: widget.uid,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
