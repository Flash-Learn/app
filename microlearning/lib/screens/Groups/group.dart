import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/Groups/edit_group.dart';

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
    return StreamBuilder(
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
            appBar: AppBar(
              title: Text(
                snapshot.data["name"],
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EditGroup(
                        groupData: group,
                      );
                    }));
                  },
                )
              ],
            ),
            body: Container(
              color: Colors.red,
              child: DeckReorderList(
                userDeckIDs: group.decks,
              ),
            ),
          );
        });
  }
}
