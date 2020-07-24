import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:microlearning/screens/Groups/edit_group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class Group extends StatefulWidget {
  final String groupID;

  Group({
    this.groupID,
  });

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return GroupList();
        }));
      },
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
            );

            return Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
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
              ),
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return GroupList();
                    }));
                  },
                ),
                title: Text(
                  snapshot.data["name"],
                ),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return EditGroup(
                          groupData: group,
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
                child: DeckReorderList(
                  userDeckIDs: group.decks,
                  belongsToGroup: true,
                  ifGrpThenID: group.groupID,
                ),
              ),
            );
          }),
    );
  }
}
