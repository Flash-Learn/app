import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/popUp.dart';

class EditGroup extends StatefulWidget {
  final GroupData groupData;
  EditGroup({@required this.groupData});
  @override
  _EditGroupState createState() => _EditGroupState(groupData: groupData);
}

class _EditGroupState extends State<EditGroup> {
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyUsers = GlobalKey<FormState>();
  String userToAdd;
  GroupData groupData;
  _EditGroupState({@required this.groupData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Group",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKeyDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        groupData.description = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Group name",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.all(12.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        groupData.description = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Group description",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.all(12.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        "Update group information!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () async {
                      await updateGroupData(groupData);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Form(
              key: _formKeyUsers,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        userToAdd = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "User email ID",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.all(12.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        'Add user',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () async {
                      bool alreadyThere = false;
                      bool doesExist = false;
                      bool didAdd = false;
                      CollectionReference userCollection =
                          Firestore.instance.collection('user_data');
                      try {
                        var user = await userCollection
                            .where("email", isEqualTo: userToAdd)
                            .getDocuments();
                        user.documents.forEach((element) {
                          doesExist = true;
                          if (groupData.users.contains(element.documentID) ==
                              false) {
                            groupData.users.add(element.documentID);
                          } else {
                            alreadyThere = true;
                          }
                        });
                      } catch (e) {
                        print(e);
                        return;
                      }
                      if (!doesExist) {
                        popUp(context, "No such user!");
                        return;
                      } else if (alreadyThere) {
                        popUp(context, "User already in group!");
                        return;
                      }
                      try {
                        await updateGroupData(groupData);
                      } catch (e) {
                        print(e);
                        return;
                      }
                      if (!didAdd) {
                        popUp(context, "Some error occured. Try again!");
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
