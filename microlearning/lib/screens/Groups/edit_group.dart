import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/popUp.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/screens/Groups/Search/group_search.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class EditGroup extends StatefulWidget {
  final GroupData groupData;
  final bool creating;
  EditGroup({@required this.groupData, this.creating: false});
  @override
  _EditGroupState createState() => _EditGroupState(groupData: groupData);
}

class _EditGroupState extends State<EditGroup> {
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyUsers = GlobalKey<FormState>();
  String userToAdd;
  GroupData groupData;
  _EditGroupState({@required this.groupData});

  onPressedBack() async {
    if (widget.creating) {
      await deleteGroup(groupData.groupID);
      Navigator.of(context).pushReplacement(FadeRoute(page: GroupList()));
    } else {
      Navigator.of(context).pushReplacement(SlideRightRoute(
          page: Group(
        groupID: groupData.groupID,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onPressedBack();
      },
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                onPressedBack();
              },
            ),
            centerTitle: true,
            title: Text(
              widget.creating ? "Create Group" : "Edit Group",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: !widget.creating
                ? <Widget>[
                    FlatButton(
                      child: Text(
                        'Leave',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        await createAlertDialogLeaveGroup(
                            context, groupData.groupID);
                      },
                    )
                  ]
                : null),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Done'),
          icon: Icon(Icons.check),
          onPressed: () async {
            if (_formKeyDetails.currentState.validate()) {
              await updateGroupData(groupData);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return Group(
                  groupID: groupData.groupID,
                );
              }));
            }
          },
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKeyDetails,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          onChanged: (val) {
                            setState(() {
                              groupData.name = val;
                            });
                          },
                          validator: (String arg) {
                            if (arg.length == 0) {
                              return 'Group name must not be empty';
                            } else {
                              return null;
                            }
                          },
                          initialValue: groupData.name,
                          decoration: inputTextDecorations('Group Name')),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                          onChanged: (val) {
                            setState(() {
                              groupData.description = val;
                            });
                          },
                          initialValue: groupData.description,
                          validator: (String arg) {
                            if (arg.length == 0) {
                              return 'Group discription must not be empty';
                            } else {
                              return null;
                            }
                          },
                          decoration:
                              inputTextDecorations('Group Description')),
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: RaisedButton(
                          color: MyColorScheme.accentLight(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            // addUserDialog(context);
                            Navigator.of(context).pushReplacement(
                                // context.
                                MaterialPageRoute(
                              builder: (context) => GroupSearch(
                                groupData: groupData,
                              ),
                            )
                                // '/groupsearch',
                                );
                          },
                          child: Text(
                            'Add a User',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.group,
                          ),
                          Text(
                            'Group Members:',
                            style: TextStyle(
                                color: MyColorScheme.accent(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView(
                            children: buildUserLists(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildUserLists() {
    return groupData.users.map<Widget>((dynamic username) {
      return StreamBuilder(
          stream: Firestore.instance
              .collection('user_data')
              .document(username)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text("loading");
            if (snapshot.data == null) return Container();
            dynamic mailID = snapshot.data["email"];
            dynamic name = snapshot.data["name"];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  name != null ? name : '',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(mailID != null ? mailID : ''),
              ),
            );
          });
    }).toList();
  }
}
