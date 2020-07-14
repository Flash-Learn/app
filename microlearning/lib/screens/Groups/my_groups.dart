import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/screens/Groups/edit_group.dart';
import 'package:microlearning/screens/Groups/init_group.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/screens/Groups/group_info_card.dart';
import 'package:microlearning/screens/authentication/init_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  GlobalKey<_GroupListState> _keySearch = GlobalKey<_GroupListState>();
  GlobalKey<_GroupListState> _keyMyDecks = GlobalKey<_GroupListState>();
  List<dynamic> userGroupIDs;
  bool _disableTouch = false;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _disableTouch,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromRGBO(84, 205, 255, 1),
              Color.fromRGBO(84, 205, 255, 1),
              Color.fromRGBO(27, 116, 210, 1)
            ])),
        child: Scaffold(
          bottomNavigationBar: customBottomNav(),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Color.fromRGBO(196, 208, 223, 0),
            // backgroundColor: Colors.blue,
            centerTitle: true,
            title: Text(
              'My Groups',
              style: TextStyle(
                  color: MyColorScheme.uno(),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
            // actions: <Widget>[
            //   IconButton(
            //     key: _keySearch,
            //     icon: Icon(
            //       Icons.search,
            //       color: MyColorScheme.uno(),
            //     ),
            //     onPressed: () {
            //       Navigator.pushNamed(
            //         context,
            //         '/groupsearch',
            //       );
            //     },
            //   ),
            // ],
            leading: IconButton(
              icon: Icon(
                Icons.account_circle,
                color: MyColorScheme.uno(),
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
            ),
          ),
          body: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx < 0) {
                //TODO: remove this.
              }
            },
            child: FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Loading');
                }
                final String uid = snapshot.data.getString('uid');
                return StreamBuilder(
                  stream: Firestore.instance
                      .collection('user_data')
                      .document(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Loading');
                    }
                    if (snapshot.data == null) {
                      return Container();
                    }
                    try {
                      userGroupIDs = snapshot.data["groups"];
                    } catch (e) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return GetUserInfo();
                      }));
                    }
                    return ReorderList(userGroupIDs: userGroupIDs);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  customBottomNav() {
    return Container(
      height: 80,
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            splashColor: MyColorScheme.accent(),
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return MyDecks();
              }));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.library_books,
                  color: MyColorScheme.uno(),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('MyDecks',
                    style: TextStyle(
                      color: MyColorScheme.uno(),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _disableTouch = true;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String uid = prefs.getString('uid');
              GroupData newGroup = await createNewGroup(uid);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) {
                  return EditGroup(groupData: newGroup);
                },
              ));
              setState(() {
                _disableTouch = false;
              });
            },
            child: Material(
              elevation: 2,
              color: Color.fromRGBO(50, 217, 157, 1),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _disableTouch
                    ? Loading(
                        size: 20,
                      )
                    : Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            color: MyColorScheme.uno(),
                          ),
                          Text(
                            'Create Group',
                            style: TextStyle(color: MyColorScheme.uno()),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.group,
                  color: Colors.amber,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'MyGroups',
                  style: TextStyle(color: Colors.amber),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ReorderList extends StatefulWidget {
  const ReorderList({
    Key key,
    @required this.userGroupIDs,
  }) : super(key: key);
  final List userGroupIDs;
  @override
  _ReorderListState createState() => _ReorderListState(userGroupIDs);
}

class _ReorderListState extends State<ReorderList> {
  _ReorderListState(this.userGroupIDs);
  List<dynamic> userGroupIDs;
  var _tapPosition;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ReorderableListView(
        scrollDirection: Axis.vertical,
        children: getGroupsAsList(context, userGroupIDs),
        onReorder: _onReorder,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex = -1;
      }
      final String item = userGroupIDs.removeAt(oldIndex);
      userGroupIDs.insert(newIndex, item);
    });
  }

  Widget buildGroupInfo(BuildContext ctxt, String groupID) {
    return groupInfoCard(groupID);
  }

  getGroupsAsList(BuildContext context, List<dynamic> userGroupIDs) {
    int i = 0;
    String k = '';
    return userGroupIDs.map<Widget>((dynamic groupID) {
      i++;
      k = '$i';
      return Container(
          height: 130,
          key: ValueKey(k),
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTapDown: (details) {
                  _tapPosition = details.globalPosition;
                },
                onTap: () {
                  //TODO: add navigation to group
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return Group(groupID: groupID);
                  }));
                },
                child: buildGroupInfo(context, groupID),
              ),
            ],
          ));
    }).toList();
  }
}
